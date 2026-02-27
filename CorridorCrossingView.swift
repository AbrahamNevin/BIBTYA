//
//  CorridorCrossingView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//

import SwiftUI

struct CorridorCrossingView: View {
    // --- POSITIONING CONFIGURATION ---
    // Change these two values to move both the Box and Biptya together
    let dockX: CGFloat = 350
    let dockY: CGFloat = 300
    
    // --- DRAG STATES ---
    @State private var isDragging: Bool = false
    @State private var biptyaOffset: CGSize = .zero
    
    @State private var isCrossing = false
    @State private var hasFinishedCrossing = false
    @State private var isPulsing = false
    @State private var goToEnding = false
    @State private var autoRotation: Double = 0.0
    
    // Target location (The Green Circle)
    let bridgeEntrance = CGSize(width: -510, height: -100)
    let snapTolerance: CGFloat = 80.0
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)
    
    // Initialize Biptya to the Dock position
    init() {
        _biptyaOffset = State(initialValue: CGSize(width: dockX, height: dockY))
    }
    
    private var currentTilt: Double {
        if isCrossing {
            return autoRotation
        } else {
            let frequency = 0.15
            let amplitude = 10.0
            return sin(biptyaOffset.width * frequency) * amplitude
        }
    }

    var body: some View {
        ZStack {
            // Background
            Image("nightCorridor")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // --- 1. THE DOCK (Orange Box) ---
            if !isCrossing {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange, lineWidth: 3)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.4)))
                        .frame(width: 180, height: 120)
                    
                    Text("BIPTYA DOCK")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                        .offset(y: -75) // Position text above the box
                }
                .offset(x: dockX, y: dockY) // Box stays fixed at these coordinates
            }
            
            // --- 2. THE TARGET VISUAL CUE ---
            if !isCrossing {
                ZStack {
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .background(Circle().fill(Color.green.opacity(0.2)))
                    Text("PLACE\nHERE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }
                .offset(bridgeEntrance)
                .scaleEffect(isPulsing ? 1.1 : 0.9)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { isPulsing = true }
                }
            }
            
            // HUD / Instructions
            VStack {
                Text(hasFinishedCrossing ? "SAFE PASSAGE" : "GUIDE BIPTYA TO THE CORRIDOR")
                    .font(.system(size: 16, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.top, 60)
                
                Spacer()
                
                if hasFinishedCrossing {
                    Button(action: { goToEnding = true }) {
                        Text("CONTINUE STORY")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding()
                            .background(biptyaColor)
                            .cornerRadius(10)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 50)
                }
            }
            
            // --- 3. THE BIPTYA (Leopard) ---
            Image("bibtya_walk")
                .resizable()
                .scaledToFit()
                // Small in box (100), large when dragging/crossing (160)
                .frame(width: (isDragging || isCrossing) ? 160 : 100)
                .rotationEffect(.degrees(currentTilt))
                .offset(biptyaOffset)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDragging)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isCrossing {
                                isDragging = true
                                // Start movement from the dock position
                                self.biptyaOffset = CGSize(
                                    width: dockX + value.translation.width,
                                    height: dockY + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            checkBridgeEntrance()
                        }
                )
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToEnding) {
            CoexistenceEndingView(useLivingCorridorPath: true)
        }
    }
    
    // Logic to check if Biptya was dropped in the right spot
    private func checkBridgeEntrance() {
        let xDist = abs(biptyaOffset.width - bridgeEntrance.width)
        let yDist = abs(biptyaOffset.height - bridgeEntrance.height)
        
        if xDist < snapTolerance && yDist < snapTolerance {
            startCrossingAnimation()
        } else {
            // Return to the exact Dock coordinates if missed
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                biptyaOffset = CGSize(width: dockX, height: dockY)
            }
        }
    }
    
    // Automated crossing animation
    private func startCrossingAnimation() {
        isCrossing = true
        
        // Walking tilt
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            autoRotation = 10.0
        }
        
        // Snap to entrance center
        withAnimation(.easeOut(duration: 0.4)) { biptyaOffset = bridgeEntrance }
        
        // Move across the screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 10.0)) {
                biptyaOffset = CGSize(width: 850, height: -80)
            }
        }
        
        // Finish sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation {
                hasFinishedCrossing = true
                autoRotation = 0
            }
        }
    }
}

// Preview provider for testing
struct CorridorCrossingView_Previews: PreviewProvider {
    static var previews: some View {
        CorridorCrossingView()
    }
}
