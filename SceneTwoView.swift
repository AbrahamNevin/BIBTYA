//
//  SceneTwoView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//
import SwiftUI
import SpriteKit

struct SceneTwoView: View {
    let didChooseCorridor: Bool
    
    @State private var showChoices = false
    @State private var goToOutcome = false
    @State private var choseSafeCrossing = false
    @State private var goToFenceBuild = false
    
    // NEW: State for Escalation Ending Navigation
    @State private var goToEscalation = false
    
    // State for the Act Title Card
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
                        VStack(spacing: 20) {
                            Text("How should Biptya cross?")
                                .font(.system(size: 40, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    choseSafeCrossing = true
                                    goToOutcome = true
                                }) {
                                    choiceButton(text: didChooseCorridor ? "USE CORRIDOR" : "LOCKED",
                                                 color: didChooseCorridor ? .orange : .gray)
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
                        .padding(.bottom, 200)
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
        
        // --- Navigation Destinations ---
        
        .navigationDestination(isPresented: $goToFenceBuild) {
            FencePlacementView()
        }
        
        // NEW: Destination for Escalation Ending
        .navigationDestination(isPresented: $goToEscalation) {
            EscalationEndingView()
        }
        
        .onAppear {
            // Act Title Sequence
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
                // The SpriteKit Game View
                SpriteView(scene: highwayGame)
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden(true)
                    
                    // Listener for Building Fences (Success Path)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToFenceBuild"))) { _ in
                        self.goToFenceBuild = true
                    }
                    
                    // NEW: Listener for Escalation (Failure/Ignore Path)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToEscalationEnding"))) { _ in
                        print("SwiftUI Received: Transition to Escalation Ending")
                        self.goToEscalation = true
                    }
            }
        }
    }
    
    func choiceButton(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .frame(width: 200, height: 80)
            .background(color.opacity(0.85))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

