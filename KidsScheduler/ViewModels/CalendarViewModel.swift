//
//  CalendarViewModel.swift
//  KidsScheduler
//
//  Manages calendar data and playdate fetching
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var playdates: [Playdate] = []
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService = FirestoreService()
    private var listener: ListenerRegistration?

    // Filter playdates for selected date
    var playdatesForSelectedDate: [Playdate] {
        playdates.filter { playdate in
            Calendar.current.isDate(playdate.startTime, inSameDayAs: selectedDate)
        }
    }

    // Get playdates for a specific date
    func playdates(for date: Date) -> [Playdate] {
        playdates.filter { playdate in
            Calendar.current.isDate(playdate.startTime, inSameDayAs: date)
        }
    }

    // Fetch playdates for current child
    func fetchPlaydates(for childId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch playdates where child is invited
            let fetchedPlaydates = try await firestoreService.query(
                collection: "playdates",
                whereField: "invitedChildren",
                isEqualTo: childId,
                as: Playdate.self
            )

            playdates = fetchedPlaydates.sorted { $0.startTime < $1.startTime }
            isLoading = false
        } catch {
            errorMessage = "Failed to load playdates: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // Listen to real-time updates
    func startListening(for childId: String) {
        // For now, just fetch once
        // Real-time listener can be added later
        Task {
            await fetchPlaydates(for: childId)
        }
    }

    func stopListening() {
        listener?.remove()
    }

    // Navigate to previous month
    func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    // Navigate to next month
    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    // Get days in current month
    func daysInMonth() -> [Date] {
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
}
