import SwiftUI
import MapKit

struct MapGroup: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let entries: [ScoreEntry]
}

struct MapView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @State private var selectedGroup: MapGroup?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var groupedLocations: [MapGroup] {
        var groups: [String: [ScoreEntry]] = [:]
        for entry in scoreManager.scoredLocations {
            let lat = String(format: "%.3f", entry.latitude ?? 0)
            let lon = String(format: "%.3f", entry.longitude ?? 0)
            let key = "\(lat)_\(lon)"
            groups[key, default: []].append(entry)
        }
        return groups.values.map { entries in
            MapGroup(
                coordinate: CLLocationCoordinate2D(
                    latitude: entries[0].latitude ?? 0,
                    longitude: entries[0].longitude ?? 0
                ),
                entries: entries
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            mapTopBar()
            
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(groupedLocations) { group in
                        Annotation("", coordinate: group.coordinate) {
                            Button(action: { selectedGroup = group }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(brutalistDark)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(cautionYellow)
                                                .overlay(Circle().stroke(brutalistDark, lineWidth: 2))
                                                .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
                                        )
                                    
                                    if group.entries.count > 1 {
                                        Text("\(group.entries.count)")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(.white)
                                            .frame(width: 18, height: 18)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(brutalistDark, lineWidth: 1.5))
                                            .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard)
                
                if let group = selectedGroup {
                    groupDetail(group: group)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func mapTopBar() -> some View {
        HStack {
            Text("MAP")
                .font(.system(size: 24, weight: .black, design: .default))
                .italic()
                .foregroundColor(brutalistDark)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = .automatic
                }
            }) {
                Text("\(scoreManager.scoredLocations.count) PINS")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(brutalistDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .buttonStyle(TactileButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func groupDetail(group: MapGroup) -> some View {
        TactileCard {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(group.entries.count) RECORD\(group.entries.count > 1 ? "S" : "") HERE")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(brutalistDark)
                        
                        Text("Top scores at this location")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { selectedGroup = nil }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(brutalistDark)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(TactileSecondaryButtonStyle())
                }
                
                ScrollView {
                    VStack(spacing: 8) {
                        let sorted = group.entries.sorted(by: { $0.score > $1.score })
                        ForEach(Array(sorted.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(Color.gray)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(GameRoute.fromRawValue(entry.game)?.displayName ?? entry.game.uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(brutalistDark)
                                
                                Spacer()
                                
                                Text("\(entry.score) PTS")
                                    .font(.system(size: 16, weight: .black, design: .monospaced))
                                    .foregroundColor(brutalistDark)
                            }
                            .padding(.vertical, 4)
                            
                            if index < sorted.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 150) // Restrict height so it doesn't take over the screen
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}
