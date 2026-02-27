//
//  FencePlacementView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//
import SwiftUI

struct FencePlacementView: View {
    @State private var goToNextScene = false
    
    // --- DOCK POSITIONS (Centered at 440) ---
    let dock1X: CGFloat = 440
    let dock1Y: CGFloat = 260
    
    let dock2X: CGFloat = 440
    let dock2Y: CGFloat = 420
    
    // State for Fence 1 (Left)
    @State private var dragOffset1: CGSize = .zero
    @State private var isPlaced1 = false
    @State private var isDragging1 = false
    
    // State for Fence 2 (Right)
    @State private var dragOffset2: CGSize = .zero
    @State private var isPlaced2 = false
    @State private var isDragging2 = false
    
    @State private var showNextButton = false
    
    // --- PLACEMENT TARGETS ---
    let target1 = CGSize(width: -350, height: 250)
    let degrees1: Double = -10.0
    let width1: CGFloat = 800.0
    
    let target2 = CGSize(width: 400, height: 120)
    let degrees2: Double = 0.0
    let width2: CGFloat = 600.0
    
    let snapTolerance: CGFloat = 60.0
    let biptyaColor = Color(red: 181/255, green: 103/255, blue: 13/255)

    init() {
        // Initialize offsets to start exactly in their respective boxes
        _dragOffset1 = State(initialValue: CGSize(width: 440, height: 260))
        _dragOffset2 = State(initialValue: CGSize(width: 440, height: 420))
    }

    var body: some View {
        ZStack {
            Image("FenceBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // --- 1. DOCK BOXES ---
            Group {
                if !isPlaced1 {
                    dockBox(label: "Fence Left", x: dock1X, y: dock1Y)
                }
                if !isPlaced2 {
                    dockBox(label: "Fence Right", x: dock2X, y: dock2Y)
                }
            }

            // 2. Target Outlines (Shadows)
            Group {
                if !isPlaced1 {
                    targetShadow(imageName: "fence_left", at: target1, degrees: degrees1, width: width1)
                }
                if !isPlaced2 {
                    targetShadow(imageName: "fence_right", at: target2, degrees: degrees2, width: width2)
                }
            }

            // 3. Draggable Fences
            fenceItem(imageName: "fence_left",
                      offset: $dragOffset1,
                      isPlaced: isPlaced1,
                      isDragging: $isDragging1,
                      target: target1,
                      degrees: degrees1,
                      fullWidth: width1,
                      dockX: dock1X,
                      dockY: dock1Y) {
                checkPlacement(for: 1)
            }
            
            fenceItem(imageName: "fence_right",
                      offset: $dragOffset2,
                      isPlaced: isPlaced2,
                      isDragging: $isDragging2,
                      target: target2,
                      degrees: degrees2,
                      fullWidth: width2,
                      dockX: dock2X,
                      dockY: dock2Y) {
                checkPlacement(for: 2)
            }

            // UI Overlay
            VStack {
                Text(isPlaced1 && isPlaced2 ? "PERIMETER SECURED" : "DRAG FENCES FROM STORAGE TO THE TARGETS")
                    .font(.system(size: 16, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.top, 60)
                
                Spacer()
                
                if showNextButton {
                    Button(action: { goToNextScene = true }) {
                        Text("CONTINUE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(biptyaColor)
                            .cornerRadius(10)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // --- THIS PART HANDLES THE NAVIGATION ---
        .navigationDestination(isPresented: $goToNextScene) {
            CoexistenceEndingView(useLivingCorridorPath: false)
        }
    }

    // MARK: - Helper Views
    
    func dockBox(label: String, x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.orange, lineWidth: 3)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.4)))
                .frame(width: 160, height: 110)
            
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.orange)
                .offset(y: -70)
        }
        .offset(x: x, y: y)
    }
    
    func targetShadow(imageName: String, at pos: CGSize, degrees: Double, width: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .rotationEffect(.degrees(degrees))
            .opacity(0.2)
            .offset(pos)
    }

    func fenceItem(imageName: String, offset: Binding<CGSize>, isPlaced: Bool, isDragging: Binding<Bool>, target: CGSize, degrees: Double, fullWidth: CGFloat, dockX: CGFloat, dockY: CGFloat, onEnd: @escaping () -> Void) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: (isDragging.wrappedValue || isPlaced) ? fullWidth : 100)
            .rotationEffect(.degrees(degrees))
            .shadow(color: .black.opacity(isPlaced ? 0 : 0.4), radius: 10)
            .offset(offset.wrappedValue)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isPlaced {
                            isDragging.wrappedValue = true
                            offset.wrappedValue = CGSize(
                                width: dockX + value.translation.width,
                                height: dockY + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        isDragging.wrappedValue = false
                        onEnd()
                    }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: offset.wrappedValue)
            .animation(.spring(), value: isDragging.wrappedValue)
    }

    // MARK: - Logic
    
    func checkPlacement(for piece: Int) {
        if piece == 1 {
            if isNear(dragOffset1, target1) {
                withAnimation(.spring()) {
                    dragOffset1 = target1
                    isPlaced1 = true
                }
            } else {
                withAnimation(.spring()) { dragOffset1 = CGSize(width: dock1X, height: dock1Y) }
            }
        } else {
            if isNear(dragOffset2, target2) {
                withAnimation(.spring()) {
                    dragOffset2 = target2
                    isPlaced2 = true
                }
            } else {
                withAnimation(.spring()) { dragOffset2 = CGSize(width: dock2X, height: dock2Y) }
            }
        }
        
        if isPlaced1 && isPlaced2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showNextButton = true }
            }
        }
    }
    
    func isNear(_ current: CGSize, _ target: CGSize) -> Bool {
        let xDist = abs(current.width - target.width)
        let yDist = abs(current.height - target.height)
        return xDist < snapTolerance && yDist < snapTolerance
    }
}

