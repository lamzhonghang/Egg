//
//  EggAni.swift
//  Egg
//
//  Created by lan on 2024/11/9.
//

import SwiftUI

struct EggAni: View {
    let imageCount = 11
    let animationSpeed = 0.18

    var body: some View {
        TimelineView(.animation) { timeline in
            // 根据时间戳获取当前帧
            let currentFrame = Int(timeline.date.timeIntervalSinceReferenceDate / animationSpeed) % imageCount + 1

            // 显示当前帧的图片
            Image("e\(currentFrame)")
                .resizable()
                .scaledToFit()
//                .frame(width: 60)
        }
//        .frame(width: 70, height: 70)
    }
}

#Preview {
    EggAni()
}
