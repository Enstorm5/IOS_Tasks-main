import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var scoreManager: ScoreManager
    
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderTimeInterval") private var reminderTimeInterval: Double = 0
    
    @State private var reminderDate: Date = Date()
    @State private var showWipeAlert: Bool = false
    
    var body: some View {
        ZStack {
            tactilePixelBackground()
            VStack(spacing: 0) {
                settingsTopBar()
                
                ScrollView {
                    VStack(spacing: 24) {
                        reminderSection()
                        dangerZoneSection()
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            if reminderTimeInterval == 0 {
               
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
                Toggle(isOn: $reminderEnabled) {
                    Text("Daily Reminder")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(brutalistDark)
                }
                .tint(cautionYellow)
                .padding(16)
                .onChange(of: reminderEnabled) { _, enabled in
                    handleToggleChange(enabled: enabled)
                }
            }
            
            if reminderEnabled {
                TactileCard {
                    DatePicker(
                        "Time",
                        selection: $reminderDate,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brutalistDark)
                    .padding(16)
                    .onChange(of: reminderDate) { _, newDate in
                        reminderTimeInterval = newDate.timeIntervalSince1970
                        updateSchedule()
                    }
                }
            }
        }
    }
    
    private func dangerZoneSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                tactileTitleAccent()
                Text("DANGER ZONE")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Color.red)
            }
            
            Button(action: { showWipeAlert = true }) {
                Text("WIPE ALL SCORES")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(TactileDynamicButtonStyle(color: .red))
            .alert(isPresented: $showWipeAlert) {
                Alert(
                    title: Text("WIPE ALL DATA?"),
                    message: Text("This will permanently delete all your game data."),
                    primaryButton: .destructive(Text("Wipe Data")) {
                        scoreManager.resetAllData()
                    },
                    secondaryButton: .cancel()
                )
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
