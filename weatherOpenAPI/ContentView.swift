//
//  ContentView.swift
//  weatherOpenAPI
//
//  Created by ธนัท แสงเพิ่ม on 7/9/2564 BE.
//

import SwiftUI

struct weatherInfo:Codable{
    let weather:[weather] //bug!
    let main:main
}

struct weather:Codable{
    let main:String
    let description:String
    let icon:String
}

struct main:Codable{
    let temp:Double
}

class ViewModel:ObservableObject{
    @Published var weatherdata:weatherInfo = weatherInfo(weather:[],main:main(temp:2))

    func fetch(){
        print("start fetch")
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Bangkok&units=metric&appid=eb8b12b596b8a5e782485bd7825e5dff") else{
            print("url error")
            return
        }
        let task = URLSession.shared.dataTask(with: url){
            data, res, err in
            guard let data = data , err == nil else{return}
            do{
                let jsondata = try JSONDecoder().decode(weatherInfo.self, from: data)
                DispatchQueue.main.async{self.weatherdata = jsondata}
                print("fetch!")
            }catch{
                print("catch \(error)")
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear(perform: viewModel.fetch)
        
        Text("\(String(format : "%.2f",viewModel.weatherdata.main.temp))")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
