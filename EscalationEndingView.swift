//
//  EscalationEndingView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//

import SwiftUI
import Charts

struct FatalityData: Identifiable {
    let id = UUID(); let year: String; let incidents: Int
}

struct EscalationEndingView: View {
    @State private var stage: Int = 0
    
    let fatalityData: [FatalityData] = [
        .init(year: "Year 0", incidents: 61), .init(year: "Year 1", incidents: 40),
        .init(year: "Year 2", incidents: 22), .init(year: "Year 3", incidents: 14),
        .init(year: "Year 4", incidents: 8), .init(year: "Year 5", incidents: 5)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if stage >= 1 && stage <= 5 {
                storySceneContent
            }

            // --- STAGE 6: Graph with 40% Opacity & Line Chart ---
                        if stage == 6 {
                            VStack(spacing: 20) {
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("“Wildlife Deaths After Corridor Installation”")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Chart(fatalityData) { item in
                                        // The Trend Line
                                        LineMark(
                                            x: .value("Year", item.year),
                                            y: .value("Incidents", item.incidents)
                                        )
                                        .interpolationMethod(.catmullRom) // Smooth curves
                                        .foregroundStyle(.orange)
                                        .lineStyle(StrokeStyle(lineWidth: 4))

                                        // Points on the line
                                        PointMark(
                                            x: .value("Year", item.year),
                                            y: .value("Incidents", item.incidents)
                                        )
                                        .foregroundStyle(item.year == "Year 0" ? .red : .orange)
                                    }
                                    .frame(height: 300)
                                }
                                .padding()
                                // Set to 0.4 (40%) opacity
                                .background(Color.black.opacity(0.4).cornerRadius(15))
                                
                                Text("“Design changes outcomes.”")
                                    .font(.title3.bold())
                                    .foregroundColor(.orange)
                                
                                Spacer()
                            }
                            .padding()
                            // Consistent "Rise from bottom" animation
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }

                        if stage == 0 { titleCard(text: "ACT 3: THE BREAKING POINT") }
                        if stage == 7 { titleCard(text: "He wasn’t in the way.\nWe were.").foregroundColor(.red) }
                    }
                    .onAppear { runEscalationSequence() }
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
        ZStack { Color.black.ignoresSafeArea(); Text(text).font(.largeTitle.bold()).multilineTextAlignment(.center).foregroundColor(.white).padding() }.transition(.opacity)
    }

    func runEscalationSequence() {
        let timings: [Double] = [3, 7, 11, 15, 19, 23, 27, 33]
        for i in 0..<timings.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + timings[i]) {
                withAnimation(.easeInOut(duration: 1.5)) { stage = i + 1 }
            }
        }
    }
}
