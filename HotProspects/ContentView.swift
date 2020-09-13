//
//  ContentView.swift
//  HotProspects
//
//  Created by Subhrajyoti Chakraborty on 12/09/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var updater = DelayedUpdater()
    
    func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void)  {
        // check the URL is OK, otherwise return with a failure
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    // success: convert the data to a string and send it back
                    let stringData = String(decoding: data, as: UTF8.self)
                    completion(.success(stringData))
                } else if error != nil {
                    // any sort of network failure
                    completion(.failure(.requestFailed))
                } else {
                    // this ought not to be possible, yet here we are
                    completion(.failure(.unknown))
                }
            }
        }.resume()
        
    }
    
    var body: some View {
        VStack {
            Text("The value is => \(updater.value)")
            Text("Hello, World!")
                .onAppear {
                    self.fetchData(from: "https://www.apple.com") { (result) in
                        switch result {
                            case .success(let str):
                                print(str)
                            case .failure(let error):
                                switch error {
                                    case .badURL:
                                        print("Bad URL")
                                    case .requestFailed:
                                        print("Network problems")
                                    case .unknown:
                                        print("Unknown error")
                            }
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum NetworkError: Error {
    case badURL, requestFailed, unknown
}

class DelayedUpdater: ObservableObject {
    var value = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    init() {
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
}
