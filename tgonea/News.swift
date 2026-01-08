//
//  News.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI

struct News: View {
    var body: some View {
        ZStack {
            Image("thanmayi")
                .resizable()
                .scaledToFit()
                .frame(width: 1000 ,height: 1000 ,alignment: .center)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    News()
}
