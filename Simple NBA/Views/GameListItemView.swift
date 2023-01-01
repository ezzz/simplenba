//
//  GameListItemView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 23/12/2022.
//

import SwiftUI

struct ListItemView: View {
    
    var game: mGame
    let iIconSize: CGFloat = 40
    let iFrameIconWidth: CGFloat = 100
    
    var body: some View {
        //GeometryReader { gp in
        HStack {
            VStack {
                Image("\(game.awayTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.awayTeamResult.teamName)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("\(game.awayTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 90)
            Spacer()
            VStack {
                if (game.status == 1) {
                    Text("\(game.statusText)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                else {
                    VStack {
                        if game.awayTeamResult.pts > game.homeTeamResult.pts {
                            HStack {
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                                Text(" - ")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        else {
                            HStack {
                                
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text(" - ")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        Text("\(game.statusText)")
                            .font(.subheadline)
                            .foregroundColor(.white)
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
                    .foregroundColor(.white)
                Text("\(game.homeTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 90)
        }
        //.padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.2),  lineWidth: 1/2)
        )
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.1)))
    }
}

