//
//  ViewModel.swift
//  jungle-book-ios-app
//
//  Created by Schablinger Mathias on 13.03.24.
//

import Foundation
class ViewModel: ObservableObject {
    @Published private(set) var model = Model()
    
    init(model: Model){
        self.model = model;
    }
    
    var journals: [Journal] {
        model.journals
    }
    var checkpoints: [Checkpoint] {
        model.checkpoints
    }
    func setJournals(journals: [Journal]) {
        model.setJournals(journals)
    }
    func journalsLoaded(_ journals: [Journal]) {
        model.setJournals(journals)
    }
    func checkpointsLoaded(_ checkpoints: [Checkpoint]) {
        model.setCheckpoints(checkpoints)
    }
    func setCheckpoints(checkpoints: [Checkpoint]) {
        model.setCheckpoints(checkpoints)
    }
}
