//
//  ScoreGapShape.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 29/12/2022.
//

import SwiftUI


struct ScoreGraphView: View {
    var game: mGame
    @StateObject var playbyplay: PlayByPlay
    let graphLineHeight = 20.0
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
                
                let widthTable = width
                let minX = (width - widthTable) / 2
                let midX = (width) / 2
                let maxX = widthTable + (width - widthTable) / 2

                // Background
                RectangleShape()
                    .fill(Color.gray).brightness(0.3)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:-graphLineHeight*3/2)
                RectangleShape()
                    .fill(Color.gray).brightness(0.25)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:-graphLineHeight*1/2)
                
                RectangleShape()
                    .fill(.gray).brightness(0.3)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:+graphLineHeight*3/2)
                RectangleShape()
                    .fill(.gray).brightness(0.25)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:+graphLineHeight*1/2)
                
                VerticalQuarterShape()
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)

                if playbyplay.dataIsLoaded {
                    //Text("Loaded \(playbyplay.timeArray.count)")

                    ScoreCurveShape(isBackground: true, playbyplay: playbyplay, line10ptsHeight: graphLineHeight)
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: .green.opacity(0.3), location: 0.5),
                                Gradient.Stop(color: .blue.opacity(0.3), location: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom))
                        .frame(width:widthTable)
                    ScoreCurveShape(isBackground: false, playbyplay: playbyplay, line10ptsHeight: graphLineHeight)
                        .stroke(LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: .green, location: 0.5),
                                Gradient.Stop(color: .blue, location: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom), style: StrokeStyle(lineWidth: 3.0, lineJoin: .round )) // , lineCap: .rounded
                        .frame(width:widthTable)
                }
                else {
                    Text("Loading...")
                    Path { path in
                        path.move(to: CGPoint(x: minX, y: height/2))
                        path.addLine(to: CGPoint(x: maxX, y: height/2 ))
                    }
                    .stroke(.red, lineWidth: 3)
                }
                
                Path { path in
                    path.move(to: CGPoint(x: minX, y: height/2))
                    path.addLine(to: CGPoint(x: maxX, y: height/2))
                }
                .stroke(Color.red.opacity(0.8), lineWidth: 1.5)
                ZStack(alignment: .trailing) {
                    Text("\(game.awayTeamResult.pts_qtr1)")
                        .offset(CGSize(width: -width*3/8, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.awayTeamResult.pts_qtr2)")
                        .offset(CGSize(width: -width*1/8, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.awayTeamResult.pts_qtr3)")
                        .offset(CGSize(width: width/8.0, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.awayTeamResult.pts_qtr4)")
                        .offset(CGSize(width: (width*3)/8.0, height: -graphLineHeight*5/2))
                        .font(.caption)

                    Text("\(game.homeTeamResult.pts_qtr1)")
                        .offset(CGSize(width: -width*3/8, height: graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.homeTeamResult.pts_qtr2)")
                        .offset(CGSize(width: -width*1/8, height: graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.homeTeamResult.pts_qtr3)")
                        .offset(CGSize(width: width/8.0, height: graphLineHeight*5/2))
                        .font(.caption)
                    Text("\(game.homeTeamResult.pts_qtr4)")
                        .offset(CGSize(width: (width*3)/8.0, height: graphLineHeight*5/2))
                        .font(.caption)

                    /*
                    Text("Q1")
                        .offset(CGSize(width: -width*3/8, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("Q2")
                        .offset(CGSize(width: -width*1/8, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("Q3")
                        .offset(CGSize(width: width*1/8.0, height: -graphLineHeight*5/2))
                        .font(.caption)
                    Text("Q4")
                        .offset(CGSize(width: (width*3)/8.0, height: -graphLineHeight*5/2))
                        .font(.caption)*/
                }
            }
        }
    }
}

struct ScoreCurveShape: Shape {
    let isBackground: Bool
    let playbyplay: PlayByPlay
    let line10ptsHeight: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        //path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        for dt in playbyplay.timeArray {
            path.addLine(to: self.getCoord(dt: dt, diff: playbyplay.diffTable[dt]!, rect: rect))
        }
        if isBackground {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }

        return path
    }
    
    func getCoord(dt: Int, diff: Int, rect: CGRect) -> CGPoint {
        let dx = rect.minX + Double(dt)/(12*4*60)*(rect.maxX - rect.minX)
        let dy = rect.midY + Double((-diff))/10.0*line10ptsHeight
        //let _ = print("\(dx)/\(rect.maxX) \(dy)/\(rect.maxY)")
        return CGPoint(x: dx, y: dy)
    }
}


struct RectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minX))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

struct VerticalQuarterShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                
        let q1X = (rect.minX + rect.midX)/2
        let q3X = (rect.midX + rect.maxX)/2
        
        path.move(to: CGPoint(x: q1X, y: rect.minY))
        path.addLine(to: CGPoint(x: q1X, y: rect.maxY))
        
        path.move(to: CGPoint(x: q3X, y: rect.minY))
        path.addLine(to: CGPoint(x: q3X, y: rect.maxY))
        
        return path
    }
}

struct ScoreGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreGraphView(game: DayGames(preview: true).getPreviewGame(), playbyplay: PlayByPlay(gameId: "0022200161", preview: true))
            .frame(width:400, height:300)
    }
}
