//
//  CubeView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//


import SwiftUI

// transforming de viewcontroller of the cube into swiftUI view
struct CubeView: UIViewControllerRepresentable {
    var viewController: CubeViewController

    func makeUIViewController(context: Context) -> CubeViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: CubeViewController, context: Context) {}
}