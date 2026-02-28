//
//  SceneOneView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//
import SwiftUI

struct SceneOneView: View {
    @State private var storyPhase = 0
    @State private var lineVisible = [false, false, false, false]
    @State private var showContinueButton = false
    @State private var goToNextScene = false
    @State private var builtBridge = false
    @State private var goToSceneOne = false // NEW: State for navigation
    
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if storyPhase >= 1 {
                    Image("Scene1Base")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(storyPhase == 1 ? 0.3 : 0.6)
                }
                
                if storyPhase == 0 {
                    Text("ACT 1: The Divided Path")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { storyPhase = 1 }
                            }
                        }
                }
                
                if storyPhase == 1 {
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(0..<4) { i in
                            if lineVisible[i] {
                                Text(getLineText(i))
                                    .foregroundColor(i == 3 ? biptyaColor : .white)
                                    .fontWeight(i == 3 ? .bold : .medium)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        
                        if showContinueButton {
                            Button(action: { withAnimation { storyPhase = 2 } }) {
                                Text("CONTINUE")
                                    .font(.system(size: 14, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(biptyaColor)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .italic()
                    .padding(60)
                    .onAppear { revealLinesSequentially() }
                }
                
                if storyPhase == 2 {
                    VStack {
                        Spacer()
                        HStack(spacing: 30) {
                            Button(action: {
                                builtBridge = true
                                goToNextScene = true
                            }) {
                                choiceButton(text: "BUILD WILDLIFE CORRIDOR", color: .orange)
                            }

                            Button(action: {
                                builtBridge = false
                                goToNextScene = true
                            }) {
                                choiceButton(text: "SPEED UP CONSTRUCTION", color: .orange)
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToNextScene) {
                // Ensure this matches the parameter name in SceneTwoView
                BridgeSceneView(didChooseCorridor: builtBridge)
            }
        }
    }
    
    private func getLineText(_ index: Int) -> String {
        let lines = [
            "Highways are rising across rural Maharashtra, cutting through endless sugarcane fields where Biptyas silently move at dusk.",
            "Construction promises progress, but it also fragments their hidden pathways, pushing them closer to human settlements.",
            "Dust settles. Machines pause. A leopard watches from the cane.",
            "Will you build for speed… or for coexistence?"
        ]
        return lines[index]
    }

    private func revealLinesSequentially() {
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.5) {
                withAnimation(.easeOut(duration: 1.0)) { lineVisible[i] = true }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation { showContinueButton = true }
        }
    }
    
    func choiceButton(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(width: 280, height: 80)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 2))
    }
}

