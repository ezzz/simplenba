//
//  GameListItemView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 23/12/2022.
//

import SwiftUI

struct ListItemView: View {
    @Environment(\.colorScheme) var colorScheme

    var game: mGame
    @Binding var hideScore: Bool
    
    let iIconSize: CGFloat = 40
    let iFrameIconWidth: CGFloat = 100
    
    var body: some View {
        //GeometryReader { gp in
        let textColor = (colorScheme == .dark ? Color.white : Color.black)
        HStack {
            VStack {
                Image("\(game.awayTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.awayTeamResult.teamName)")
                    .font(.footnote)
                    .foregroundColor(textColor)
                Text("\(game.awayTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
            }
            .frame(maxWidth: 90)
            Spacer()
            VStack {
                if (game.status == 1) {
                    Text("\(game.statusText)")
                        .font(.subheadline)
                        .foregroundColor(textColor)
                }
                else {
                    VStack {
                        if game.awayTeamResult.pts > game.homeTeamResult.pts {
                            HStack {
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title2)
                                    .bold()
                                Text(" - ")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title3)
                            }
                        }
                        else {
                            HStack {
                                
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title3)
                                Text(" - ")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        Text("\(game.statusText)")
                            .font(.subheadline)
                            .foregroundColor(game.status == 2 ? .red : textColor)
                            .padding(3)
                    }
                }
            }
            Spacer()
            VStack {
                Image("\(game.homeTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.homeTeamResult.teamName)")
                    .font(.footnote)
                    .foregroundColor(textColor)
                Text("\(game.homeTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(textColor.opacity(hideScore ? 0.0 : 1.0))
            }
            .frame(maxWidth: 90)
        }
        //.padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.2),  lineWidth: 0)
        )
        .background(RoundedRectangle(cornerRadius: 8).fill(colorScheme == .dark ? Color(hue: 1.0, saturation: 0.0, brightness: (0.15)) : .white))
    }
}


struct Previews_GameListItemView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
