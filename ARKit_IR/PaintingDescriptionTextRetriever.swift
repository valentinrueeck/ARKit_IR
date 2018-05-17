//
//  PaintingDescriptionTextRetriever.swift
//  Image Recognition
//
//  Created by Valentin Rüeck on 08.05.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import Foundation

func retrieveDescriptionText(name: String) -> String {
    switch name {
    case "Segelboote":
        return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    case "VanGogh":
        return "Van Gogh Van Gogh Van Gogh Van Gogh   Van Gogh Van Gogh Van Gogh"
    case "Wald":
        return "Wald (Waldung) im alltagssprachlichen Sinn und im Sinn der meisten Fachsprachen ist ein Ausschnitt der Erdoberfläche, der mit Bäumen bedeckt ist und die eine gewisse, vom Deutungszusammenhang abhängige Mindestdeckung und Mindestgröße überschreitet. Die Definition von Wald ist notwendigerweise vage[1] und hängt vom Bedeutungszusammenhang (alltagssprachlich, geographisch, biologisch, juristisch, ökonomisch, kulturell …) ab."
    default:
        return ""
    }
}

//private func informationService(name: String){
//    let url = "http://en.wikipedia.org/w/api.php?format=json&action=parse&page=\(name)&prop=text&section=0"
//    var request = NSMutableURLRequest() as URLRequest
//    request.url = URL(string: url)
//    request.httpMethod = "GET"
//
//    NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue(), completionHandler: { (response:URLResponse!, data: NSData!, error: NSError!) -> Void in
//        var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
//        let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
//
//        if (jsonResult != nil) {
//            // process jsonResult
//        } else {
//            // couldn't load JSON, look at error
//        }
//
//
//    })
//}

//func requestInformation(name: String){
//    let urlString = "http://en.wikipedia.org/w/api.php?format=json&action=parse&page=\(name)&prop=text&section=0"
//    guard let url = URL(string: urlString) else { return }
//
//    URLSession.shared.dataTask(with: url) { (data, response, error) in
//        if error != nil {
//            print(error!.localizedDescription)
//        }
//
//        guard let data = data else { return }
//        //Implement JSON decoding and parsing
//        do {
//            //Decode retrived data with JSONDecoder and assing type of Article object
//            let information = try JSONDecoder().decode([Article].self, from: data)
//
//        } catch let jsonError {
//            print(jsonError)
//        }
//
//
//        }.resume()
//
//}

