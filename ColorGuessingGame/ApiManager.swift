//
//  ApiManager.swift
//  ColorGuessingGame
//
//  Created by Student on 4/30/26.
//

import Foundation
import SwiftUI

func callAPI(r: Int, g: Int, b: Int) async throws -> ColorResponse?{
    let urlStr: String = "https://www.thecolorapi.com/id?rgb=\(r),\(g),\(b)&format=json"
    let url: URL? = URL(string: urlStr)
    guard let urlUnwrapped = url else {
        return nil
    }
    do {
        let (data, response) = try await URLSession.shared.data(from: urlUnwrapped)
        let responseConverted = response as! HTTPURLResponse
        let colorResponse: ColorResponse = try JSONDecoder().decode(ColorResponse.self, from:data)
        return colorResponse
    } catch let error {
        print(error)
    }
    return nil
}

func fetchColorResponse(from url: URL) async throws -> ColorResponse? {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(ColorResponse.self, from: data)
}
