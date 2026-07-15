import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderTimeInterval") private var reminderTimeInterval: Double = 0
    
    @State private var reminderDate: Date = Date()
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            VStack(spacing: 0) {
                settingsTopBar()
                
                ScrollView {
                    VStack(spacing: 24) {
                        reminderSection()
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            if reminderTimeInterval == 0 {
                // Default to 8:00 PM
                var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                components.hour = 20
                components.minute = 0
                if let defaultDate = Calendar.current.date(from: components) {
                    reminderDate = defaultDate
                    reminderTimeInterval = defaultDate.timeIntervalSince1970
                }
            } else {
                reminderDate = Date(timeIntervalSince1970: reminderTimeInterval)
            }
        }
    }
    
    private func settingsTopBar() -> some View {
        HStack {
            Text("SETTINGS")
                .font(.system(size: 24, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func reminderSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("NOTIFICATIONS")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(brutalistDark)
            }
            
            TactileCard {
                VStack(spacing: 0) {
                    Toggle(isOn: $reminderEnabled) {
                        Text("Daily Reminder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(brutalistDark)
                    }
                    .tint(cautionYellow)
                    .padding(16)
                    .onChange(of: reminderEnabled) { enabled in
                        handleToggleChange(enabled: enabled)
                    }
                    
                    if reminderEnabled {
                        Rectangle()
                            .fill(brutalistDark)
                            .frame(height: 2)
                        
                        DatePicker(
                            "Time",
                            selection: $reminderDate,
                            displayedComponents: .hourAndMinute
                        )
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(brutalistDark)
                        .padding(16)
                        .background(panelBg)
                        .onChange(of: reminderDate) { newDate in
                            reminderTimeInterval = newDate.timeIntervalSince1970
                            updateSchedule()
                        }
                    }
                }
            }
        }
    }
    
    private func handleToggleChange(enabled: Bool) {
        if enabled {
            notificationManager.requestPermission { granted in
                if granted {
                    updateSchedule()
                } else {
                    reminderEnabled = false
                }
            }
        } else {
            notificationManager.cancelReminders()
        }
    }
    
    private func updateSchedule() {
        guard reminderEnabled else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        if let h = components.hour, let m = components.minute {
            notificationManager.scheduleDailyReminder(hour: h, minute: m)
        }
    }
}
