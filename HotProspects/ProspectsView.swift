//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Subhrajyoti Chakraborty on 15/09/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI
import CodeScanner

struct ProspectsView: View {
    let filter: FilterType
    var title: String {
        switch filter {
            case .none:
                return "Everyone"
            case .contacted:
                return "Contacted people"
            case .uncontacted:
                return "Uncontacted people"
        }
    }
    var filteredProspects: [Prospect] {
        switch filter {
            case .none:
                return prospects.people
            case .contacted:
                return prospects.people.filter { $0.isContacted }
            case .uncontacted:
                return prospects.people.filter{ !$0.isContacted }
        }
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
            case .success(let code):
                let details = code.components(separatedBy: "\n")
                guard details.count == 2 else { return }
                
                let person = Prospect()
                person.name = details[0]
                person.emailAddress = details[1]
                self.prospects.people.append(person)
            case .failure(let error):
                print("Scanning failed")
                print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAddress)
                            .foregroundColor(.secondary)
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: self.handleScan)
            })
                .navigationBarTitle(title)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingScanner = true
                }, label: {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }))
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}

enum FilterType {
    case none, contacted, uncontacted
}
