//
//  StandingsView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/12/2022.
//

import SwiftUI

struct StandingsView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: DetailView()) {
                Text("Tap Me")
            }
        }
        
    }
}

struct DetailView: View {
    
    var body: some View {
        
        Text("Hello, I'm a Detail View")
        
    }
}
       


struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView()
    }
}
