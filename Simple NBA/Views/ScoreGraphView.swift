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
            let widthTable = width
            let minX = (width - widthTable) / 2
            let maxX = widthTable + (width - widthTable) / 2

            ZStack {
                
                // Background
                Group {
                    RectangleShape()
                        .withRank(rank: -2, rectWidth: widthTable, rectHeight: graphLineHeight)
                    RectangleShape()
                        .withRank(rank: -1, rectWidth: widthTable, rectHeight: graphLineHeight)
                    RectangleShape()
                        .withRank(rank: 1, rectWidth: widthTable, rectHeight: graphLineHeight)
                    RectangleShape()
                        .withRank(rank: 2, rectWidth: widthTable, rectHeight: graphLineHeight)
                    if self.playbyplay.numExtraLines > 0 {
                        ForEach(0..<Int(self.playbyplay.numExtraLines)) { x in
                            RectangleShape()
                                .withRank(rank: -3-x, rectWidth: widthTable, rectHeight: graphLineHeight)
                            RectangleShape()
                                .withRank(rank: 3+x, rectWidth: widthTable, rectHeight: graphLineHeight)
                        }
                    }
                    
                    VerticalQuarterShape(numOT: playbyplay.numOverTime)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                }
                
                Path { path in
                    path.move(to: CGPoint(x: minX, y: height/2))
                    path.addLine(to: CGPoint(x: maxX, y: height/2))
                }
                .stroke(Color.red.opacity(0.8), lineWidth: 1.5)
                

                if playbyplay.dataIsLoaded {
                    //Text("Loaded \(playbyplay.timeArray.count)")

                    ScoreCurveShape(isBackground: true, playbyplay: playbyplay, line10ptsHeight: graphLineHeight)
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: game.colorAway!.opacity(0.3), location: 0.5),
                                Gradient.Stop(color: game.colorHome!.opacity(0.3), location: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom))
                        .frame(width:widthTable)
                    ScoreCurveShape(isBackground: false, playbyplay: playbyplay, line10ptsHeight: graphLineHeight)
                        .stroke(LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: game.colorAway!, location: 0.5),
                                Gradient.Stop(color: game.colorHome!, location: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom), style: StrokeStyle(lineWidth: 2.0, lineJoin: .round )) // , lineCap: .rounded
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
                
                ZStack(alignment: .trailing) {
                    QuarterScoreTextView(pts: game.awayTeamResult.pts_qtr1, qtr: 1, home: -1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.homeTeamResult.pts_qtr1, qtr: 1, home: 1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.awayTeamResult.pts_qtr2, qtr: 2, home: -1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.homeTeamResult.pts_qtr2, qtr: 2, home: 1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.awayTeamResult.pts_qtr3, qtr: 3, home: -1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.homeTeamResult.pts_qtr3, qtr: 3, home: 1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.awayTeamResult.pts_qtr4, qtr: 4, home: -1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    QuarterScoreTextView(pts: game.homeTeamResult.pts_qtr4, qtr: 4, home: 1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    if game.awayTeamResult.pts_ot1 > 0 || game.homeTeamResult.pts_ot1 > 0 {
                        QuarterScoreTextView(pts: game.awayTeamResult.pts_ot1, qtr: 5, home: -1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                        QuarterScoreTextView(pts: game.homeTeamResult.pts_ot1, qtr: 5, home: 1, width: width, lineHeight: graphLineHeight, playbyplay: playbyplay)
                    }
                }
            }
        }
    }
    
}

struct QuarterScoreTextView: View {
    let pts, qtr, home: Int
    let width, lineHeight: CGFloat
    @StateObject var playbyplay: PlayByPlay
    
    var body: some View {
        Text("\(pts)")
            .offset(CGSize(width: getX(), height: getY()))
            .font(.subheadline)
    }
    
    func getX() -> CGFloat {
        let offsetX = -width/2
        let x = width*CGFloat(1+2*(qtr-1))/8.0
        let a = x*12*4
        let b = CGFloat(12*4+5*playbyplay.numOverTime)
        return a/b-width/2
    }
    
    func getY() -> CGFloat {
        // Width :
        // Qtr
        // 1 -> -3
        // 2 -> -1
        // 3 ->
        // => -5+qtr*2

        let height1 = CGFloat(5+2*playbyplay.numExtraLines)
        return CGFloat(home)*lineHeight*(height1)/2
    }
        
    func getXforOt(ot: Int, rect: CGRect) -> CGFloat {
        let a = rect.maxX*(12*4+(CGFloat(ot))*5)
        let b = 12*4+5*CGFloat(playbyplay.numOverTime)
        return a/b
    }

}

struct ScoreCurveShape: Shape {
    let isBackground: Bool
    let playbyplay: PlayByPlay
    let line10ptsHeight: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        var lastX = CGFloat(0)
        for dt in playbyplay.timeArray {
            let coord = self.getCoord(dt: dt, diff: playbyplay.diffTable[dt]!, rect: rect)
            path.addLine(to: coord)
            lastX = coord.x
        }
        if isBackground {
            path.addLine(to: CGPoint(x: lastX, y: rect.midY))
        }

        return path
    }
    
    func getCoord(dt: Int, diff: Int, rect: CGRect) -> CGPoint {
        let dx = rect.minX + Double(dt)/(12*4*60+Double(playbyplay.numOverTime)*5*60)*(rect.maxX - rect.minX)
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

extension Shape {
    func withRank(rank: Int, rectWidth: CGFloat, rectHeight: CGFloat) -> some View {
        self
            .fill(Color.gray).brightness(getAlpha(rank: rank))
            .frame(width:rectWidth, height: rectHeight)
            .offset(x:0, y:getY(rectHeight: rectHeight, rank: rank))
    }
    
    func getY(rectHeight: CGFloat, rank: Int) -> CGFloat {
        var correctedRank = rank
        if correctedRank > 0 {
            correctedRank = correctedRank - 1
        }
        return rectHeight*(1 + 2*CGFloat(correctedRank))/2
    }
    func getAlpha(rank: Int) -> CGFloat {
        var correctedRank = rank
        if correctedRank > 0 {
            correctedRank = correctedRank - 1
        }
        return 0.25 + 0.05*CGFloat(correctedRank % 2)
    }
}


struct VerticalQuarterShape: Shape {
    let numOT: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: getXforQt(numQt:1, rect: rect), y: rect.minY))
        path.addLine(to: CGPoint(x: getXforQt(numQt:1, rect: rect), y: rect.maxY))
                
        path.move(to: CGPoint(x: getXforQt(numQt:2, rect: rect), y: rect.minY))
        path.addLine(to: CGPoint(x: getXforQt(numQt:2, rect: rect), y: rect.maxY))
                
        path.move(to: CGPoint(x: getXforQt(numQt:3, rect: rect), y: rect.minY))
        path.addLine(to: CGPoint(x: getXforQt(numQt:3, rect: rect), y: rect.maxY))
                
        if numOT > 0 {
            for ot in 0..<numOT {
                path.move(to: CGPoint(x: getXforOt(ot:ot, rect: rect), y: rect.minY))
                path.addLine(to: CGPoint(x: getXforOt(ot:ot, rect: rect), y: rect.maxY))
            }
        }
            
        return path
    }
    
    func getXforQt(numQt: Int, rect: CGRect) -> CGFloat {
        var x = CGFloat.zero
        if numQt == 1 {
            x = (rect.minX + rect.midX)/2
        }
        else if numQt == 2 {
            x = rect.midX
        }
        else if numQt == 3 {
            x = (rect.midX + rect.maxX)/2
        }
        let a = x*12*4
        let b = 12*4+5*CGFloat(numOT)
        return a/b
    }
    
    func getXforOt(ot: Int, rect: CGRect) -> CGFloat {
        let a = rect.maxX*(12*4+(CGFloat(ot))*5)
        let b = 12*4+5*CGFloat(numOT)
        return a/b
    }
}

struct ScoreGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreGraphView(game: DayGames(preview: true).getPreviewGame(), playbyplay: PlayByPlay(gameId: "0022200161", homeTeamTricode: "SAS", preview: true))
            .frame(width:400, height:300)
    }
}
