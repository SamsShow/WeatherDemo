//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 20/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: WeatherManager.ResponseBody?
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    WeatherView(weather: weather)
                } else {
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            } catch {
                                print("Error Fetching Weather Data:", error)
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
