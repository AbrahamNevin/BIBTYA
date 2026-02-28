import SwiftUI
import Charts

struct FatalityData: Identifiable {
    let id = UUID(); let year: String; let incidents: Int
}

struct EscalationEndingView: View {
    let didSpeedUpConstruction: Bool
    
    @State private var stage: Int = 0
    @State private var goToSceneOne = false
    
    // Logic for the 10-second delay
    @State private var showFinalText = false
    @State private var finalOverlayOpacity: Double = 0.0
    
    // Brand Color
    let biptyaOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    
    let fatalityData: [FatalityData] = [
        .init(year: "Year 0", incidents: 61), .init(year: "Year 1", incidents: 40),
        .init(year: "Year 2", incidents: 22), .init(year: "Year 3", incidents: 14),
        .init(year: "Year 4", incidents: 8), .init(year: "Year 5", incidents: 5)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
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
                        .transition(.opacity)
                    }

                    // --- STAGE 7: Final Scene ---
                    if stage >= 7 {
                        ZStack {
                            Image(didSpeedUpConstruction ? "Flow3" : "Flow4")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                                .overlay(Color.black.opacity(finalOverlayOpacity))
                            
                            if showFinalText {
                                VStack(spacing: 40) {
                                    Text("He wasn’t in the way.\nWe were.")
                                        .font(.system(size: 40, weight: .bold, design: .serif))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .shadow(radius: 10)
                                        .padding()
                                    
                                    // UPDATED: Standardized Button Style
                                    Button(action: { goToSceneOne = true }) {
                                        choiceButton(text: "PLAY AGAIN", color: biptyaOrange)
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .transition(.opacity)
                    }

                    // --- STAGE 0: Opening Title ---
                    if stage == 0 { titleCard(text: "ACT 3: THE BREAKING POINT") }
                }
            }
            .onAppear {
                AudioManager.shared.playBackgroundMusic(fileName: "natureMusic", loops: -1)
                runEscalationSequence()
            }
            .navigationDestination(isPresented: $goToSceneOne) {
                SceneOneView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // Standardized Button ViewBuilder
    @ViewBuilder
    func choiceButton(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 280, height: 70)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
            )
    }

    // MARK: - Subviews
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
        GeometryReader { geo in
            ZStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.4))
                
                VStack {
                    Spacer()
                    Text(text)
                        .font(.title2.italic())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.6))
                }
            }
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

    // MARK: - Sequence Logic
    func runEscalationSequence() {
        let timings: [Double] = [3, 7, 11, 15, 19, 23, 27]
        for i in 0..<timings.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + timings[i]) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    stage = i + 1
                }
                
                if stage == 7 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            self.finalOverlayOpacity = 0.5
                            self.showFinalText = true
                        }
                    }
                }
            }
        }
    }
}
