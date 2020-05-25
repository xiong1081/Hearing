//
//  ContentView.swift
//  Hearing
//
//  Created by 李招雄 on 2020/5/24.
//  Copyright © 2020 李招雄. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        Button(action: {
            self.userData.hearingOpen = !self.userData.hearingOpen
            if self.userData.hearingOpen {
                AudioRecorder.shared.record()
            } else {
                AudioRecorder.shared.stop()
            }
        }) {
            Text(self.userData.hearingOpen ? "关闭" : "开启")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
