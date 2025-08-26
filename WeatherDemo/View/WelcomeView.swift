//
//  WelcomeView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 25/08/25.
//

//
//  WelcomeView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 25/08/25.
//

import SwiftUI
import CoreLocationUI

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var animateElements = false
    @State private var animateBackground = false
    @State private var showLocationButton = false
    @State private var pulseEffect = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background with particles
                WelcomeBackground()
                
                // Floating weather icons
                FloatingWeatherIcons(screenSize: geometry.size)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 40) {
                        // Hero section with animated icon
                        VStack(spacing: 24) {
                            // Large weather icon with animation
                            ZStack {
                                // Pulsing background circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseEffect)
                                
                                // Main weather icon
                                Image(systemName: "cloud.sun.rain.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(animateElements ? 1.0 : 0.3)
                                    .rotationEffect(.degrees(animateElements ? 0 : -45))
                                    .animation(.spring(response: 1.2, dampingFraction: 0.6).delay(0.3), value: animateElements)
                            }
                            .offset(y: floatingOffset)
                            .onAppear {
                                // Floating animation
                                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                                    floatingOffset = -10
                                }
                                pulseEffect = true
                            }
                            
                            // Welcome text with staggered animation
                            VStack(spacing: 16) {
                                Text("Welcome to")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .opacity(animateElements ? 1 : 0)
                                    .offset(y: animateElements ? 0 : 30)
                                    .animation(.spring(response: 0.8).delay(0.6), value: animateElements)
                                
                                Text("WeatherPro")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .cyan.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .opacity(animateElements ? 1 : 0)
                                    .offset(y: animateElements ? 0 : 30)
                                    .animation(.spring(response: 0.8).delay(0.8), value: animateElements)
                            }
                        }
                        
                        // Description card
                        VStack(spacing: 20) {
                            Text("Get accurate weather forecasts\nfor your current location")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : 20)
                                .animation(.spring(response: 0.8).delay(1.0), value: animateElements)
                            
                            // Feature highlights
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                                FeatureHighlight(icon: "location.fill", title: "Live Location", delay: 1.2)
                                FeatureHighlight(icon: "thermometer.medium", title: "Real-time", delay: 1.4)
                                FeatureHighlight(icon: "clock.fill", title: "Hourly Forecast", delay: 1.6)
                            }
                            .opacity(animateElements ? 1 : 0)
                            .animation(.spring(response: 0.8).delay(1.2), value: animateElements)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Location permission section
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.cyan)
                                .opacity(showLocationButton ? 1 : 0)
                                .scaleEffect(showLocationButton ? 1 : 0.3)
                                .animation(.spring(response: 0.8).delay(1.8), value: showLocationButton)
                            
                            Text("We need your location to provide\naccurate weather information")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .opacity(showLocationButton ? 1 : 0)
                                .offset(y: showLocationButton ? 0 : 20)
                                .animation(.spring(response: 0.8).delay(2.0), value: showLocationButton)
                        }
                        
                        // Enhanced location button
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            locationManager.requestLocation()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Share Current Location")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(LocationButtonStyle())
                        .opacity(showLocationButton ? 1 : 0)
                        .offset(y: showLocationButton ? 0 : 50)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(2.2), value: showLocationButton)
                        
                        // Privacy note
                        Text("Your location data stays private and secure")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .opacity(showLocationButton ? 1 : 0)
                            .animation(.spring(response: 0.8).delay(2.4), value: showLocationButton)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animateElements = true
            animateBackground = true
        }
        
        withAnimation(.spring(response: 0.8).delay(1.8)) {
            showLocationButton = true
        }
    }
}

// MARK: - Welcome Background
struct WelcomeBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.6, saturation: 0.8, brightness: 0.4),
                    Color(hue: 0.65, saturation: 0.9, brightness: 0.6),
                    Color(hue: 0.7, saturation: 0.7, brightness: 0.5)
                ]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: animateGradient)
            
            // Overlay for depth
            LinearGradient(
                colors: [.black.opacity(0.1), .clear, .black.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
        }
    }
}

// MARK: - Feature Highlight
struct FeatureHighlight: View {
    let icon: String
    let title: String
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.spring(response: 0.8).delay(delay), value: animate)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Floating Weather Icons
struct FloatingWeatherIcons: View {
    let screenSize: CGSize
    @State private var positions: [CGPoint] = []
    @State private var animating = false
    
    let icons = ["cloud.fill", "sun.max.fill", "cloud.rain.fill", "cloud.snow.fill", "wind"]
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                if positions.indices.contains(index) {
                    Image(systemName: icons[index])
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.1))
                        .position(positions[index])
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: animating
                        )
                }
            }
        }
        .onAppear {
            generateRandomPositions()
            animating = true
        }
    }
    
    private func generateRandomPositions() {
        positions = (0..<5).map { _ in
            CGPoint(
                x: CGFloat.random(in: 50...(screenSize.width - 50)),
                y: CGFloat.random(in: 100...(screenSize.height - 200))
            )
        }
        
        // Create floating movement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            positions = positions.map { position in
                CGPoint(
                    x: position.x + CGFloat.random(in: -30...30),
                    y: position.y + CGFloat.random(in: -50...50)
                )
            }
        }
    }
}

// MARK: - Location Button Style
struct LocationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#Preview {
    WelcomeView()
        .environmentObject(LocationManager())
}
