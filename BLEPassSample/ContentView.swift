//
//  ContentView.swift
//  BLEPassSample
//
//  Created by user on 2022/07/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        HStack {
            TextField("번호입력", text: $viewModel.id)
                .frame(width: 200, alignment: .center)
                .textFieldStyle(.roundedBorder)
            Button("문열기", action: viewModel.setupCentralManager)
                .disabled(viewModel.id.isEmpty)
                .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
