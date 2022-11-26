//
//  GameView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 22/11/2022.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    func HeaderView() -> some View {
        
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Text("Games")
                    .foregroundColor(.primary)
                    .font(.largeTitle.bold())
                Spacer()
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height:  45)
                //.padding(.bottom, -5)
            }
            .hLeading()
            Text("Coucou")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
