//
//  CoexistenceEndingView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 24/02/26.
//

import SwiftUI
import Charts

// MARK: - Data Models
struct LeopardData: Identifiable {
    let id = UUID()
    let year: Int
    let deaths: Int
}

struct CrossingData: Identifiable {
    let id = UUID()
    let year: Int
    let crossings: Int
}

struct CoexistenceEndingView: View {
    @State private var stage: Int = 0
    @State private var showLine1 = false
    @State private var showLine2 = false
    @State private var showLine3 = false
    
    let mortalityData: [LeopardData] = [
        .init(year: 2012, deaths: 14), .init(year: 2013, deaths: 16),
        .init(year: 2014, deaths: 18), .init(year: 2015, deaths: 21),
        .init(year: 2016, deaths: 24), .init(year: 2017, deaths: 12),
        .init(year: 2018, deaths: 9), .init(year: 2019, deaths: 7),
        .init(year: 2020, deaths: 5)
    ]
    
    let crossingData: [CrossingData] = [
        .init(year: 2014, crossings: 38),
        .init(year: 2016, crossings: 52),
        .init(year: 2018, crossings: 74),
        .init(year: 2020, crossings: 91)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if stage >= 1 {
                Image("CoexistenceBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.5))
                    .transition(.opacity)
                
                // --- STAGE 1 & 4 Overlay Text ---
                VStack {
                    if stage == 1 {
                        Spacer() // Pushes text to the middle
                        Text("“Progress is not just measured in kilometers of road,\nbut in lives safely preserved alongside it.”")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(40)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                        Spacer() // Keeps text in the middle
                    }
                    
                    if stage == 4 {
                        Spacer() // Centers the final group
                        VStack(spacing: 25) {
                            if showLine1 {
                                Text("“When roads slow down, forests breathe.”")
                                    .italic()
                                // Same animation: Rise from bottom + Fade in
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            
                            if showLine2 {
                                Text("“Between 2016 and 2020, leopard deaths fell by over 75%.”")
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            
                            if showLine3 {
                                Text("“Coexistence is not an idea. It is infrastructure.”")
                                    .fontWeight(.black)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        Spacer() // Keeps text centered
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // --- DATA VISUALIZATION (Stage 2 & 3) ---
            VStack(spacing: 30) {
                // First Graph: Mortality
                if stage == 2 {
                    VStack(alignment: .leading) {
                        Text(" Leopard Mortality (Before vs After Mitigation)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Chart(mortalityData) { item in
                            LineMark(
                                x: .value("Year", item.year),
                                y: .value("Deaths", item.deaths)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            PointMark(
                                x: .value("Year", item.year),
                                y: .value("Deaths", item.deaths)
                            )
                            .annotation(position: .top) {
                                Text("\(item.deaths)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 700)
                        .chartXScale(domain: 2011...2021)
                        
                        Text(" NH7 – National Highway 44 Wildlife Corridor")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.4).cornerRadius(15))
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                }
                
                // Second Graph: Crossings (Now converted to Line Graph)
                if stage == 3 {
                    VStack(alignment: .leading) {
                        Text(" Wildlife Crossings Per Month (Line Trend)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Chart(crossingData) { item in
                            LineMark(
                                x: .value("Year", String(item.year)),
                                y: .value("Crossings", item.crossings)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.green.gradient)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            PointMark(
                                x: .value("Year", String(item.year)),
                                y: .value("Crossings", item.crossings)
                            )
                            .annotation(position: .top) {
                                Text("\(item.crossings)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 700)
                        
                        Text(" Average crossings trending upwards following infrastructure.")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.4).cornerRadius(15))
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                }
            }
            .padding()

            if stage == 0 {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("ACT III: The Living Corridor")
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .tracking(6)
                        .foregroundColor(.white)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            runEndingSequence()
        }
    }

    func runEndingSequence() {
        // Stage 0 -> 1 (Title to Background)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 1.5)) { stage = 1 }
        }
        
        // Stage 1 -> 2 (Mortality Graph)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            withAnimation(.easeInOut) { stage = 2 }
        }
        
        // Stage 2 -> 3 (Crossing Graph)
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) {
            withAnimation(.easeInOut) { stage = 3 }
        }
        
        // Stage 3 -> 4 (Final Sequence Starts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 19.5) {
            withAnimation(.easeInOut) { stage = 4 }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                showLine1 = true
            }
            withAnimation(.easeInOut(duration: 1.0).delay(2.5)) {
                showLine2 = true
            }
            withAnimation(.easeInOut(duration: 1.0).delay(4.5)) {
                showLine3 = true
            }
        }
    }
}
