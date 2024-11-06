//
//  ContentView.swift
//  Egg
//
//  Created by lan on 2024/11/6.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("egg")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .foregroundColor(.black)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
