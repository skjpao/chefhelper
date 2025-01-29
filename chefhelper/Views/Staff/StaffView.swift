import SwiftUI
import SwiftData

struct StaffView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var staff: [Staff]
    @State private var selectedTab = 0
    @State private var selectedWeek = Date()
    @State private var showingAddStaff = false
    @State private var selectedStaff: Staff?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selection
                Picker("view".localized, selection: $selectedTab) {
                    Text("calendar".localized).tag(0)
                    Text("staff".localized).tag(1)
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
                            Text("add_first_staff".localized)
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
            .navigationTitle("staff".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.brown)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == 1 {
                        Button(action: { showingAddStaff = true }) {
                            Label("add_staff".localized, systemImage: "person.badge.plus")
                        }
                        .tint(.brown)
                    }
                }
            }
            .sheet(isPresented: $showingAddStaff) {
                AddStaffView()
            }
            .sheet(item: $selectedStaff) { staff in
                EditStaffView(staff: staff)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private func deleteStaff(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(staff[index])
        }
    }
} 
