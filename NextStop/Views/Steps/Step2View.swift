//
//  Step2View.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI

struct Step2View: View {
    @Binding var searchText: String
    let filteredStations: [Station]
    var selectAction: (Station) -> Void
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 2: Select your destination ")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                TextField("Type at least 3 letters...", text: $searchText)
                    .foregroundColor(.white)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .padding(.horizontal)
            
            ForEach(filteredStations) { station in
                Button {
                    selectAction(station)
                } label: {
                    HStack {
                        Text(station.destination)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                }
                .padding(.horizontal)
            }
            
            Button("Back", action: backAction)
                .padding(.horizontal)
        }
    }
}

