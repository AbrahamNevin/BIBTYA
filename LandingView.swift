//
//  LandingView.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 24/02/26.
//

import SwiftUI

struct LandingView: View {
    
    @State private var showInfo = false
    
    let biptyaColor = Color(
        red: 181/255,
        green: 103/255,
        blue: 13/255
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("Landingscreen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        showInfo = true
                    }) {
                        Text("S T A R T")
                            // UPDATED: Custom font applied here
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 70)
                            .padding(.vertical, 22)
                            .background(
                                ZStack {
                                    biptyaColor
                                    
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.black.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 4)
                            )
                            .shadow(color: Color.black.opacity(0.3),
                                    radius: 10, x: 5, y: 10)
                    }
                    .rotation3DEffect(.degrees(-15), axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(.degrees(2))
                    .offset(x: 38)
                    .padding(.bottom, 210)
                }
            }
            .navigationDestination(isPresented: $showInfo) {
                InfoView()
            }
        }
    }
}
