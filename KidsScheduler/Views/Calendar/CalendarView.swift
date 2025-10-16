//
//  CalendarView.swift
//  KidsScheduler
//
//  Main calendar view with month/week display
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedChild: Child?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month navigation header
                MonthHeaderView(
                    currentMonth: viewModel.currentMonth,
                    onPrevious: { viewModel.previousMonth() },
                    onNext: { viewModel.nextMonth() }
                )

                // Calendar grid
                CalendarGridView(
                    currentMonth: viewModel.currentMonth,
                    selectedDate: $viewModel.selectedDate,
                    playdates: viewModel.playdates
                )

                Divider()

                // Selected day's playdates
                PlaydateListView(
                    playdates: viewModel.playdatesForSelectedDate,
                    selectedDate: viewModel.selectedDate
                )
            }
            .navigationTitle("My Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.selectedDate = Date()
                        viewModel.currentMonth = Date()
                    }) {
                        Text("Today")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            // TODO: Get current child from auth context
            // For now, using mock data
            if DEBUG_MODE {
                viewModel.playdates = Playdate.mockPlaydates
            }
        }
    }
}

// MARK: - Month Header
struct MonthHeaderView: View {
    let currentMonth: Date
    let onPrevious: () -> Void
    let onNext: () -> Void

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
            }
        }
        .padding()
    }
}

// MARK: - Calendar Grid
struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let playdates: [Playdate]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var daysInMonth: [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        var dates: [Date] = []
        var date = monthFirstWeek.start

        while date < monthLastWeek.end {
            dates.append(date)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 10) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Calendar days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        isInMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasPlaydates: hasPlaydates(on: date)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private func hasPlaydates(on date: Date) -> Bool {
        playdates.contains { playdate in
            Calendar.current.isDate(playdate.startTime, inSameDayAs: date)
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isInMonth: Bool
    let hasPlaydates: Bool

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 18, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)

            if hasPlaydates {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private var textColor: Color {
        if !isInMonth {
            return .gray.opacity(0.3)
        } else if isSelected {
            return .blue
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isToday {
            return Color.blue.opacity(0.1)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Playdate List
struct PlaydateListView: View {
    let playdates: [Playdate]
    let selectedDate: Date

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateString)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            if playdates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No playdates scheduled")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Create a playdate to get started!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(playdates) { playdate in
                            PlaydateCardView(playdate: playdate)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Playdate Card
struct PlaydateCardView: View {
    let playdate: Playdate

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: playdate.startTime)
    }

    private var activityEmoji: String {
        switch playdate.activityType {
        case .park: return "🏞️"
        case .sports: return "⚽"
        case .art: return "🎨"
        case .gaming: return "🎮"
        case .movie: return "🎬"
        case .study: return "📚"
        case .birthday: return "🎂"
        case .other: return "📌"
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            // Activity icon
            Text(activityEmoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(playdate.title)
                    .font(.headline)

                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(timeString)
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)

                if let location = playdate.location {
                    HStack {
                        Image(systemName: "mappin.circle")
                            .font(.caption)
                        Text(location.name)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }

                // RSVP Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        // For now, show pending - will be replaced with actual RSVP status
        switch playdate.status {
        case .confirmed: return .green
        case .pending: return .orange
        case .cancelled: return .red
        case .completed: return .gray
        }
    }

    private var statusText: String {
        switch playdate.status {
        case .confirmed: return "Confirmed"
        case .pending: return "Pending"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }
}

// MARK: - Mock Data for Testing
extension Playdate {
    static var mockPlaydates: [Playdate] {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!

        return [
            Playdate(
                id: "mock1",
                groupId: "group1",
                createdBy: "child1",
                createdByParentId: "parent1",
                title: "Park Playdate",
                description: "Let's play at the park!",
                activityType: .park,
                startTime: today.addingTimeInterval(3600 * 3), // 3 hours from now
                endTime: today.addingTimeInterval(3600 * 5),
                location: PlaydateLocation(name: "Central Park", address: "123 Park Ave"),
                invitedChildren: ["child1", "child2"],
                rsvps: [],
                status: .pending,
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Playdate(
                id: "mock2",
                groupId: "group1",
                createdBy: "child2",
                createdByParentId: "parent2",
                title: "Soccer Practice",
                description: "Weekend soccer!",
                activityType: .sports,
                startTime: tomorrow.addingTimeInterval(3600 * 4),
                endTime: tomorrow.addingTimeInterval(3600 * 6),
                location: PlaydateLocation(name: "Soccer Field", address: "456 Sports Ave"),
                invitedChildren: ["child1", "child2", "child3"],
                rsvps: [],
                status: .confirmed,
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Playdate(
                id: "mock3",
                groupId: "group2",
                createdBy: "child1",
                createdByParentId: "parent1",
                title: "Art Class",
                description: "Painting session",
                activityType: .art,
                startTime: nextWeek,
                endTime: nextWeek.addingTimeInterval(3600 * 2),
                location: PlaydateLocation(name: "Community Center", address: "789 Art St"),
                invitedChildren: ["child1", "child3"],
                rsvps: [],
                status: .pending,
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
