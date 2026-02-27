import SwiftUI
import SpriteKit

struct SceneTwoView: View {
    let didChooseCorridor: Bool
    
    @State private var showChoices = false
    @State private var goToOutcome = false
    @State private var choseSafeCrossing = false
    @State private var goToFenceBuild = false
    @State private var goToEscalation = false
    @State private var showTitleCard = true
    
    var highwayGame: SKScene {
        let scene = HighwayScene(size: UIScreen.main.bounds.size)
        scene.didChooseCorridor = self.didChooseCorridor
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        ZStack {
            // 1. The Main Scene Content
            ZStack {
                Image(didChooseCorridor ? "Scene2WithBridge" : "Scene2EmptyHighway")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("“The forest has changed. Hunger has not.”")
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.white)
                        .padding(30)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    if showChoices {
                        VStack(spacing: 30) {
                            Text("How should Biptya cross?")
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            HStack(spacing: 30) {
                                Button(action: {
                                    choseSafeCrossing = true
                                    goToOutcome = true
                                }) {
                                    choiceButton(
                                        text: didChooseCorridor ? "USE CORRIDOR" : "LOCKED",
                                        color: didChooseCorridor ? .orange : .gray.opacity(0.5)
                                    )
                                }
                                .disabled(!didChooseCorridor)
                                
                                Button(action: {
                                    choseSafeCrossing = false
                                    goToOutcome = true
                                }) {
                                    choiceButton(text: "CROSS HIGHWAY", color: .orange)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .opacity(showTitleCard ? 0 : 1)
            
            // 2. The Intro Title Card Overlay
            if showTitleCard {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("ACT 2: The Crossing")
                        .font(.system(size: 35, weight: .black, design: .serif))
                        .tracking(4)
                        .foregroundColor(.white)
                }
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToFenceBuild) {
            FencePlacementView()
        }
        .navigationDestination(isPresented: $goToEscalation) {
            EscalationEndingView(didSpeedUpConstruction: !didChooseCorridor)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    showTitleCard = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showChoices = true
                    }
                }
            }
        }
        .navigationDestination(isPresented: $goToOutcome) {
            if choseSafeCrossing {
                CorridorCrossingView()
            } else {
                SpriteView(scene: highwayGame)
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden(true)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToFenceBuild"))) { _ in
                        self.goToFenceBuild = true
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToEscalationEnding"))) { _ in
                        self.goToEscalation = true
                    }
            }
        }
    }
    
    // Updated function to match SceneOneView's aesthetic
    func choiceButton(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(width: 250, height: 80) // Standard size for consistency
            .background(Color.black.opacity(0.8)) // Darker background for contrast
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2) // The signature outline
            )
    }
}
