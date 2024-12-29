//
//  ContentView.swift
//  Snake
//
//  Created by Ryan Coughlin on 12/23/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
