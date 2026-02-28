import SwiftUI
import AVFoundation
struct BridgeSceneView: View {
    let didChooseCorridor: Bool
    
    @State private var goToSceneTwo = false
    @State private var isPlaced: Bool = false
    @State private var showNextButton: Bool = false
    @State private var sliderValue: Double = 0.0
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    @State private var shakeOffset: CGFloat = 0 // Controls the screen rumble
    // --- DRAG STATES ---
    @State private var isDragging: Bool = false
    //@State private var dragOffset: CGSize = CGSize(width: 455, height: 385)
    // Initial position starts at the Dock (Right Side)
    @State private var dragOffset: CGSize = CGSize(width: 455, height: 385)
    
    // Target location on the highway
    let targetLocation = CGSize(width: 160, height: -90)
    let snapTolerance: CGFloat = 80.0
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)
    
    var body: some View {
            // Wrap everything in a Black ZStack to stop the white flashes
            ZStack {
                Color.black.ignoresSafeArea() // This covers the "white" gaps during shakes
                
                // --- THE SHAKING CONTENT ---
                Group {
                    backgroundLayer
                    
                    if !didChooseCorridor {
                        excavatorLayer
                    }
                }
                .offset(x: shakeOffset) // Apply shake to the group
                
                // --- UI LAYER (Doesn't shake) ---
                VStack {
                    instructionBox
                    if !didChooseCorridor && sliderValue >= 100 { completionMessage }
                    Spacer()
                    if !didChooseCorridor && !showNextButton { constructionSlider }
                    if showNextButton { continueButton }
                }
                
                if didChooseCorridor { corridorDragLogic }
            }
            .onAppear {
                setupAudioSession()
                
                // Check if the bundle can see ANY files
                let path = Bundle.main.path(forResource: "ConstructionSound", ofType: "mp3")
                print("DEBUG: Audio path is \(path ?? "NOT FOUND")")
                
                AudioManager.shared.playBackgroundMusic(fileName: "ConstructionSound")
            }.onDisappear {
                AudioManager.shared.stopMusic()
                print("DEBUG: Left BridgeSceneView, music stopped.")
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToSceneTwo) {
                SceneTwoView(didChooseCorridor: didChooseCorridor)
            }
        }
    
    
    private var backgroundLayer: some View {
            Group {
                if didChooseCorridor {
                    Image(isPlaced ? "Scene1Base" : "ConstructionSpedUpBG")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(isPlaced ? 1.0 : 0.6)
                } else {
                    GeometryReader { geo in
                        ZStack {
                            Image("Road_Phase1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                            
                            Image("Road_Phase2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .opacity(max(0, min(1, (sliderValue - 20) / 40)))
                            
                            Image("Road_Phase3")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .opacity(max(0, min(1, (sliderValue - 60) / 40)))
                        }
                    }
                    .ignoresSafeArea()
                }
            }
        }
    private var excavatorLayer: some View {
            Image("excavator")
                .resizable()
                .scaledToFit()
                .frame(width: 600)
                .offset(
                    x: CGFloat(sin(sliderValue * 0.5) * 10),
                    y: -150 + (CGFloat(sliderValue) * 2) + CGFloat(cos(sliderValue * 0.8) * 15)
                )
                .animation(.interactiveSpring(), value: sliderValue)
        }
    
    private var instructionBox: some View {
        Text(didChooseCorridor ?
             (isPlaced ? "WAY SECURED" : "DRAG BRIDGE FROM DOCK TO HIGHWAY") :
             (sliderValue >= 100 ? "CONSTRUCTION COMPLETE" : "SLIDE TO SPEED UP"))
            .font(.system(size: 16, weight: .black))
            .tracking(2)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
            .padding(.top, 50)
    }
    private func triggerVisualShake() {
            // Increased intensity slightly for iPad
            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.15)) {
                shakeOffset = 8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                shakeOffset = 0
            }
        }

    private var constructionSlider: some View {
            VStack {
                Slider(value: $sliderValue, in: 0...100, step: 0.5)
                    .accentColor(biptyaColor)
                    .frame(width: 500)
                    .onChange(of: sliderValue) { newValue in
                        // Shake the screen every time the percentage increases by a whole number
                        if Int(newValue) % 5 == 0 {
                            triggerVisualShake()
                        }
                        
                        if newValue >= 100 {
                            withAnimation { showNextButton = true }
                        }
                    }
                Text("\(Int(sliderValue))% COMPLETE").foregroundColor(.white).bold()
            }
            .padding(.bottom, 100)
        }
    private var continueButton: some View {
        Button(action: { goToSceneTwo = true }) {
            Text("CONTINUE JOURNEY")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .padding()
                .background(biptyaColor)
                .cornerRadius(10)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .padding(.bottom, 50)
    }

    private var completionMessage: some View {
        Text("The highway is completed ahead of schedule.\nNo safety measures were installed.")
            .font(.system(size: 18, weight: .medium, design: .serif)).italic()
            .multilineTextAlignment(.center).foregroundColor(.white)
            .padding().background(Color.black.opacity(0.4)).cornerRadius(10)
    }

    private func setupAudioSession() {
           
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default, options: [])
            try? session.setActive(true)
        }

   
        private var corridorDragLogic: some View {
            ZStack {
                // 1. THE DOCK (Source Box) - Instant disappearance
                if !isPlaced {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.orange, lineWidth: 3)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.4)))
                            .frame(width: 180, height: 120)
                        
                        Text("BRIDGE DOCK")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                            .offset(y: -75)
                    }
                    .position(x: UIScreen.main.bounds.width - 120, y: (UIScreen.main.bounds.height / 2) + 350)
                    // Removed .transition here for instant removal
                }

                // 2. THE GHOST TARGET
                if !isPlaced {
                    Image("bridge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1200)
                        .opacity(0.2)
                        .offset(targetLocation)
                }

                // 3. THE ACTUAL BRIDGE
                Image("bridge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: (isDragging || isPlaced) ? 1200 : 150)
                    .shadow(color: .black.opacity(isPlaced ? 0 : 0.6), radius: 10)
                    .offset(dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDragging)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isPlaced {
                                    isDragging = true
                                    self.dragOffset = CGSize(
                                        width: 455 + value.translation.width,
                                        height: 385 + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                                checkPlacement()
                            }
                    )
            }
        }
        
        private func checkPlacement() {
            let xDist = abs(dragOffset.width - targetLocation.width)
            let yDist = abs(dragOffset.height - targetLocation.height)
            
            if xDist < snapTolerance && yDist < snapTolerance {
                triggerSuccessHaptic()
                
                // Set this first without animation so the Dock disappears instantly
                isPlaced = true
                
                // Animate only the bridge snapping into place
                withAnimation(.spring()) {
                    dragOffset = targetLocation
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation { showNextButton = true }
                }
            } else {
                triggerHaptic(.medium)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    dragOffset = CGSize(width: 455, height: 385)
                }
            }
        }
}
