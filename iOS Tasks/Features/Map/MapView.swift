import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @State private var selectedEntry: ScoreEntry?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            mapTopBar()
            
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(scoreManager.scoredLocations) { entry in
                        Annotation("", coordinate: CLLocationCoordinate2D(
                            latitude: entry.latitude ?? 0,
                            longitude: entry.longitude ?? 0
                        )) {
                            Button(action: { selectedEntry = entry }) {
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
                            }
                        }
                    }
                }
                .mapStyle(.standard)
                
                if let entry = selectedEntry {
                    pinDetail(entry: entry)
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
                    .background(
                        cautionYellow
                            .border(brutalistDark, width: 2)
                            .shadow(color: brutalistDark, radius: 0, x: 3, y: 3)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 2).foregroundColor(brutalistDark), alignment: .bottom)
    }
    
    private func pinDetail(entry: ScoreEntry) -> some View {
        TactileCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(GameRoute.fromRawValue(entry.game)?.displayName ?? entry.game.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(brutalistDark)
                    
                    Text("\(entry.score) PTS")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(brutalistDark)
                    
                    Text(sharedDateFormatter.string(from: entry.date))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Button(action: { selectedEntry = nil }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(brutalistDark)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(TactileSecondaryButtonStyle())
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    

}
