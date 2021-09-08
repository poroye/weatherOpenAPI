//
//  ContentView.swift
//  weatherOpenAPI
//
//  Created by ธนัท แสงเพิ่ม on 7/9/2564 BE.
//

import SwiftUI

extension String{
    func load() -> UIImage{
        do{
            guard let url = URL(string:self)else{
                print("url not correct")
                return UIImage()
            }
            let data:Data = try Data(contentsOf: url)
            print("load image complete")
            return UIImage(data:data) ?? UIImage()
        }catch{
            print("catch")
            return UIImage()
        }
    }
}

struct weatherInfo:Codable{
    let weather:[weatherDes]
    let main:main
}

struct weatherDes:Codable{
    let main:String
    let description:String
    let icon:String
}

struct main:Codable{
    let temp:Double
    let humidity:Double
}

struct AirInfo:Codable{
    let list:[airDetail]
}

struct airDetail:Codable{
    let main:aqiDetail
    let components:quality
}

struct aqiDetail:Codable{
    let aqi:Int
}

struct quality:Codable{
    let co:Double
    let no:Double
    let no2:Double
    let o3:Double
    let so2:Double
    let pm2_5:Double
    let pm10:Double
    let nh3:Double
}

class ViewModel:ObservableObject{
    
    let now = Date()
    
    @Published var weatherdata:weatherInfo = weatherInfo(weather:[weatherDes(main:"x",description: "x",icon:"x")],main:main(temp:2,humidity:3))
    
    @Published var airdata:AirInfo = AirInfo(list: [airDetail(main: aqiDetail(aqi: 3), components: quality(co: 1, no: 1, no2: 1, o3: 1, so2: 1, pm2_5: 1, pm10: 1, nh3: 1))])

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
//                print(jsondata)
//                print(jsondata.weather[0].main)
            }catch{
                print("catch \(error)")
            }
        }
        task.resume()
        
        guard let url2 = URL(string: "https://api.openweathermap.org/data/2.5/air_pollution?lat=13.69&lon=100.7501&appid=eb8b12b596b8a5e782485bd7825e5dff") else{
            print("url2 error")
            return
        }
        let task2 = URLSession.shared.dataTask(with: url2){
            data, res, err in
            guard let data = data , err == nil else{return}
            do{
                let jsondata = try JSONDecoder().decode(AirInfo.self, from: data)
                DispatchQueue.main.async{self.airdata = jsondata}
                print("fetch2!")
//                print(jsondata)
                print(self.airdata.list[0].main.aqi)
            }catch{
                print("catch \(error)")
            }
        }
        task2.resume()
    }
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        Text("weather app")
            .onAppear(perform: viewModel.fetch)
            .font(.largeTitle)
        Spacer()
        HStack{
            Image(uiImage: "https://openweathermap.org/img/wn/\(viewModel.weatherdata.weather[0].icon)@4x.png".load())
            Text("\(String(format : "%.1f",viewModel.weatherdata.main.temp)) C")
                .font(.largeTitle)
        }
        Text(viewModel.weatherdata.weather[0].main).padding()
        Text(viewModel.weatherdata.weather[0].description).padding()
        Spacer()
        VStack{
            Text("humidity : \(String(format : "%.2f",viewModel.weatherdata.main.humidity))").padding()
            if viewModel.airdata.list[0].main.aqi == 1{
                Text("air quality is good").padding()
            }else if viewModel.airdata.list[0].main.aqi == 2{
                Text("air quality is fair").padding()
            }else if viewModel.airdata.list[0].main.aqi == 3{
                Text("air quality is moderate").padding()
            }else if viewModel.airdata.list[0].main.aqi == 4{
                Text("air quality is poor").padding()
            }else{
                Text("air quality is very poor").padding()
            }
//            Text("\(viewModel.airdata.list[0].main.aqi)")
        }
        HStack{
            Spacer()
            VStack{
                Text("CO")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.co))")
            }
            Spacer()
            VStack{
                Text("NO")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.no))")
            }
            Spacer()
            VStack{
                Text("NO2")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.no2))")
            }
            Spacer()
            VStack{
                Text("O3")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.o3))")
            }
            Spacer()
        }.padding(.all)
        HStack{
            Spacer()
            VStack{
                Text("SO2")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.so2))")
            }
            Spacer()
            VStack{
                Text("PM25")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.pm2_5))")
            }
            Spacer()
            VStack{
                Text("PM10")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.pm10))")
            }
            Spacer()
            VStack{
                Text("nh3")
                Text("\(String(format : "%.2f",viewModel.airdata.list[0].components.nh3))")
            }
            Spacer()
        }
            .padding(.all)
        Text("\(viewModel.now)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
