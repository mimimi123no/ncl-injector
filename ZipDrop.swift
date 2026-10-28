// ZipDrop — tien ich nho: chon 1 file .zip va luu vao Documents cua chinh app.
// Dung de gui file qua AirDrop roi sap xep lai cho gon.
//
// Khong dung API private, khong mang, khong quyen dac biet.

import SwiftUI
import UniformTypeIdentifiers

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let size: Int
    let date: Date
}

final class Store: ObservableObject {
    @Published var items: [Item] = []
    @Published var message = "Chon file .zip de luu vao app"

    var docs: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func reload() {
        let fm = FileManager.default
        var out: [Item] = []
        if let kids = try? fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
            for u in kids {
                let sz = (try? u.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                let dt = (try? u.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
                out.append(Item(name: u.lastPathComponent, size: sz, date: dt))
            }
        }
        items = out.sorted { $0.date > $1.date }
        message = "\(items.count) file trong Documents"
    }

    func save(_ url: URL) {
        let fm = FileManager.default
        let dst = docs.appendingPathComponent(url.lastPathComponent)
        do {
            if fm.fileExists(atPath: dst.path) { try fm.removeItem(at: dst) }
            try fm.copyItem(at: url, to: dst)
            message = "Da luu \(url.lastPathComponent)"
            reload()
        } catch {
            message = "Loi: \(error.localizedDescription)"
        }
    }

    func delete(_ it: Item) {
        try? FileManager.default.removeItem(at: docs.appendingPathComponent(it.name))
        reload()
    }
}

struct ContentView: View {
    @StateObject private var st = Store()
    @State private var pick = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text(st.message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button {
                    pick = true
                } label: {
                    Label("Chon file .zip", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                List {
                    ForEach(st.items) { it in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(it.name).font(.system(.body, design: .monospaced))
                                Text("\(it.size / 1024) KB").font(.caption2).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                st.delete(it)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("ZipDrop")
            .onAppear { st.reload() }
            .sheet(isPresented: $pick) {
                Picker { url in
                    pick = false
                    if let u = url { st.save(u) }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct Picker: UIViewControllerRepresentable {
    var done: (URL?) -> Void

    func makeCoordinator() -> C { C(done: done) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.zip, .data], asCopy: true)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}

    final class C: NSObject, UIDocumentPickerDelegate {
        let done: (URL?) -> Void
        init(done: @escaping (URL?) -> Void) { self.done = done }
        func documentPicker(_ c: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            done(urls.first)
        }
        func documentPickerWasCancelled(_ c: UIDocumentPickerViewController) { done(nil) }
    }
}

@main
struct ZipDropApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
