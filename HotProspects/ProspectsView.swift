//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Subhrajyoti Chakraborty on 15/09/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    let simulatedData = ["Paul Hudson\npaul@hackingwithswift.com", "Subha Chakraborty\nsubha@ss.com", "James Bower\njames@gmail.com"]
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
    @State private var isShowingSortOptions = false
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
            case .success(let code):
                let details = code.components(separatedBy: "\n")
                guard details.count == 2 else { return }
                
                let person = Prospect()
                person.name = details[0]
                person.emailAddress = details[1]
                
                let date = Date()
                let currentTime = Int(date.timeIntervalSince1970)
                person.createdAt = currentTime
                
                self.prospects.add(person)
            case .failure(let error):
                print("Scanning failed")
                print(error.localizedDescription)
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Testing purpose
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                    if success {
                        addRequest()
                    } else {
                        print("Permission denied!")
                    }
                }
            }
        }
        
    }
    
    func sortListByName() {
        self.prospects.sortByName(filterType: self.filter)
    }
    
    func sortListByRecent() {
        self.prospects.sortByRecent()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if (filter == .none) && (prospect.isContacted) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .actionSheet(isPresented: $isShowingSortOptions, content: {
                ActionSheet(title: Text("Sort Options"), message: nil, buttons: [.default(Text("By Name"), action: {
                    self.sortListByName()
                }), .default(Text("By Recent"), action: {
                    self.sortListByRecent()
                }), .cancel()])
            })
            .sheet(isPresented: $isShowingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: self.simulatedData.randomElement()!, completion: self.handleScan)
            })
            .navigationBarTitle(title)
            .navigationBarItems(leading: Button(action: {
                self.isShowingSortOptions = true
            }, label: {
                Image(systemName: "arrow.up.arrow.down.circle")
                Text("Sort")
            }), trailing: Button(action: {
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
