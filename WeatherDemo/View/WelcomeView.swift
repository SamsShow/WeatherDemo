//
//  WelcomeView.swift
//  ExpenseTracker
//
//  Created by Saksham Tyagi on 25/08/25.
//

import SwiftUI
import CoreLocationUI

struct WelcomeView: View {
    @EnvironmentObject var locationManger: LocationManager
    
    var body: some View {
        VStack {
            VStack(spacing: 20){
                Text("Welcome to The Weather APP").bold().font(.title)
                
                Text("Please Share your Location to get the weather").padding( )
            }.multilineTextAlignment(.center)
                .padding()
            
            LocationButton(.shareCurrentLocation){locationManger.requestLocation()}.cornerRadius(30).symbolVariant(.fill).foregroundStyle(Color.white)
        
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}
