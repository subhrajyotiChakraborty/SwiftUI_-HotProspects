//
//  ContentView.swift
//  HotProspects
//
//  Created by Subhrajyoti Chakraborty on 12/09/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let user = User()
    var body: some View {
        //        VStack {
        //            EditView().environmentObject(user)
        //            DisplayView().environmentObject(user)
        //        }
        
        //        Both works exactly same way now we place user in ContentView's environment
        
        VStack {
            EditView()
            DisplayView()
        }.environmentObject(user)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct EditView: View {
    @EnvironmentObject var user: User
    var body: some View {
        TextField("Name", text: $user.name)
    }
}

struct DisplayView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        Text(user.name)
    }
}

class User: ObservableObject {
    @Published var name = "Taylor Swift"
}
