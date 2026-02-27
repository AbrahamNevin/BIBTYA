import SwiftUI

struct BridgeSceneView: View {
    let didChooseCorridor: Bool
    
    @State private var goToSceneTwo = false
    @State private var isPlaced: Bool = false
    @State private var showNextButton: Bool = false
    @State private var sliderValue: Double = 0.0
    
    // --- DRAG STATES ---
    @State private var isDragging: Bool = false
    // Initial position starts at the Dock (Right Side)
    @State private var dragOffset: CGSize = CGSize(width: 455, height: 385)
    
    // Target location on the highway
    let targetLocation = CGSize(width: 160, height: -90)
    let snapTolerance: CGFloat = 80.0
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)
    
    var body: some View {
        ZStack {
            // --- BACKGROUND LOGIC ---
            backgroundLayer
            
            // --- EXCAVATOR LOGIC (For Road Path) ---
            if !didChooseCorridor {
                excavatorLayer
            }
            
            // --- UI OVERLAYS ---
            VStack {
                instructionBox
                
                if !didChooseCorridor && sliderValue >= 100 {
                    completionMessage
                }
                
                Spacer()
                
                if !didChooseCorridor && !showNextButton {
                    constructionSlider
                }
                
                if showNextButton {
                    continueButton
                }
            }
            
            // --- BRIDGE DRAG & DROP (For Corridor Path) ---
            if didChooseCorridor {
                corridorDragLogic
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToSceneTwo) {
            // Pass the choice to the next scene
            SceneTwoView(didChooseCorridor: didChooseCorridor)
        }
    }
    
    // MARK: - Components
    
    private var backgroundLayer: some View {
        Group {
            if didChooseCorridor {
                // Background for Corridor Path
                Image(isPlaced ? "Scene1Base" : "ConstructionSpedUpBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(isPlaced ? 1.0 : 0.6)
            } else {
                // Background for Road Path (Fixed to fill screen)
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
    
    private var constructionSlider: some View {
        VStack {
            Slider(value: $sliderValue, in: 0...100, step: 0.5)
                .accentColor(biptyaColor)
                .frame(width: 500)
                .onChange(of: sliderValue) { newValue in
                    if newValue >= 100 { withAnimation { showNextButton = true } }
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

    // MARK: - Drag & Drop Logic
    
    private var corridorDragLogic: some View {
        ZStack {
            // 1. THE DOCK (Source Box)
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.orange, lineWidth: 3)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.4)))
                .frame(width: 180, height: 120)
                .position(x: UIScreen.main.bounds.width - 120, y: (UIScreen.main.bounds.height / 2) + 350)
                .overlay(
                    Text("BRIDGE DOCK")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                        .position(x: UIScreen.main.bounds.width - 120, y: (UIScreen.main.bounds.height / 2) + 275)
                )

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
                                    width: -455 + value.translation.width,
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
            withAnimation(.spring()) {
                dragOffset = targetLocation
                isPlaced = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showNextButton = true }
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                dragOffset = CGSize(width: 455, height: 385)
            }
        }
    }
}
