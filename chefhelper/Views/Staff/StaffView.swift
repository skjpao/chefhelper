import SwiftUI
import SwiftData

struct StaffView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var staff: [Staff]
    @State private var showingAddStaff = false
    @State private var selectedStaff: Staff?
    @State private var selectedWeek = Date()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selection
                Picker("Näkymä", selection: $selectedTab) {
                    Text("Kalenteri").tag(0)
                    Text("Työntekijät").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.brown.opacity(0.1))
                
                if selectedTab == 0 {
                    // Calendar view
                    WeekScheduleView(selectedWeek: $selectedWeek, staff: staff)
                } else {
                    // Staff list view
                    List {
                        if staff.isEmpty {
                            Text("Ei henkilöstöä")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(staff) { person in
                                StaffRowView(person: person)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedStaff = person
                                    }
                            }
                            .onDelete(perform: deleteStaff)
                        }
                    }
                }
            }
            .navigationTitle("Henkilöstö")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedTab == 1 {
                    Button(action: { showingAddStaff = true }) {
                        Label("Lisää työntekijä", systemImage: "person.badge.plus")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showingAddStaff) {
                AddStaffView()
            }
            .sheet(item: $selectedStaff) { staff in
                EditStaffView(staff: staff)
            }
        }
    }
    
    private func deleteStaff(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(staff[index])
        }
    }
} 