//
//  FirestoreService.swift
//  KidsScheduler
//
//  Generic Firestore CRUD operations
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - Generic CRUD Operations

    func create<T: Encodable>(collection: String, data: T) async throws -> String {
        let ref = try db.collection(collection).addDocument(from: data)
        return ref.documentID
    }

    func read<T: Decodable>(collection: String, documentId: String, as type: T.Type) async throws -> T {
        let document = try await db.collection(collection).document(documentId).getDocument()
        return try document.data(as: type)
    }

    func update<T: Encodable>(collection: String, documentId: String, data: T) async throws {
        try db.collection(collection).document(documentId).setData(from: data, merge: true)
    }

    func delete(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }

    func query<T: Decodable>(collection: String, whereField: String, isEqualTo value: Any, as type: T.Type) async throws -> [T] {
        let snapshot = try await db.collection(collection)
            .whereField(whereField, isEqualTo: value)
            .getDocuments()

        return try snapshot.documents.map { try $0.data(as: type) }
    }

    // MARK: - Real-time Listeners

    func listen<T: Decodable>(collection: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) -> ListenerRegistration {
        return db.collection(collection).document(documentId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.documentNotFound))
                return
            }

            do {
                let data = try snapshot.data(as: type)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

enum FirestoreError: LocalizedError {
    case documentNotFound

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        }
    }
}
