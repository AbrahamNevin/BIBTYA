import SwiftUI
import Charts

struct FatalityData: Identifiable {
    let id = UUID(); let year: String; let incidents: Int
}

struct EscalationEndingView: View {
    // This value is passed from the previous view
    let didSpeedUpConstruction: Bool
    
    @State private var stage: Int = 0
    @State private var goToSceneOne = false
    
    let fatalityData: [FatalityData] = [
        .init(year: "Year 0", incidents: 61), .init(year: "Year 1", incidents: 40),
        .init(year: "Year 2", incidents: 22), .init(year: "Year 3", incidents: 14),
        .init(year: "Year 4", incidents: 8), .init(year: "Year 5", incidents: 5)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // --- STAGES 1-5: The Story ---
            if stage >= 1 && stage <= 5 {
                storySceneContent
            }

            // --- STAGE 6: The Graph ---
            if stage == 6 {
                VStack(spacing: 20) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 15) {
                        Text("“Wildlife Deaths After Corridor Installation”")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Chart(fatalityData) { item in
                            LineMark(
                                x: .value("Year", item.year),
                                y: .value("Incidents", item.incidents)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 4))

                            PointMark(
                                x: .value("Year", item.year),
                                y: .value("Incidents", item.incidents)
                            )
                            .foregroundStyle(item.year == "Year 0" ? .red : .orange)
                        }
                        .frame(height: 300)
                    }
                    .padding()
                    .background(Color.black.opacity(0.4).cornerRadius(15))
                    
                    Text("“Design changes outcomes.”")
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
                .padding()
                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
            }

            // --- STAGE 0: Opening Title ---
            if stage == 0 { titleCard(text: "ACT 3: THE BREAKING POINT") }
            
            // --- STAGE 7: Final Scene (Persists) ---
            if stage >= 7 {
                ZStack {
                    // Logic: Choice determines the background image
                    Image(didSpeedUpConstruction ? "Flow3" : "Flow4")
                                            .resizable()
                                            .scaledToFill()
                                            .ignoresSafeArea()
                                            .overlay(Color.black.opacity(0.5))
                    
                    VStack(spacing: 40) {
                        Text("He wasn’t in the way.\nWe were.")
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button(action: {
                            goToSceneOne = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Play Again")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Capsule().stroke(Color.white, lineWidth: 2))
                            .background(Color.black.opacity(0.3).clipShape(Capsule()))
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear { runEscalationSequence() }
        .navigationDestination(isPresented: $goToSceneOne) {
            SceneOneView()
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    var storySceneContent: some View {
        switch stage {
        case 1: storyScene(image: "scene1", text: "The road was built to connect cities.\nBut it also divided a forest.")
        case 2: storyScene(image: "scene2", text: "When corridors disappear,\nmovement becomes risk.")
        case 3: storyScene(image: "scene3", text: "When wild spaces shrink,\nsurvival pushes boundaries.")
        case 4: storyScene(image: "scene4", text: "Fear turns into action.\nAction turns into loss.")
        case 5: storyScene(image: "scene5", text: "Infrastructure connects people.\nBut without planning…\nit can disconnect life.")
        default: EmptyView()
        }
    }

    func storyScene(image: String, text: String) -> some View {
        ZStack {
            Image(image).resizable().scaledToFill().ignoresSafeArea().overlay(Color.black.opacity(0.4))
            VStack { Spacer(); Text(text).font(.title2.italic()).foregroundColor(.white).multilineTextAlignment(.center).padding(40).background(Color.black.opacity(0.6)) }
        }.transition(.opacity)
    }

    func titleCard(text: String) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(text)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
        }.transition(.opacity)
    }

    func runEscalationSequence() {
        let timings: [Double] = [3, 7, 11, 15, 19, 23, 27] // 7 Stages
        for i in 0..<timings.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + timings[i]) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    stage = i + 1
                }
            }
        }
    }
}
