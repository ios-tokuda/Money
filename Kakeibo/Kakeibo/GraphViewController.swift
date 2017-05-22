//
//  GraphViewController.swift
//  Kakeibo
//
//  Created by 伊東康太 on 2017/05/21.
//  Copyright © 2017年 Wittgenstein. All rights reserved.
//


//とりあえず1週間分表示
import UIKit
import RealmSwift
import Charts

class GraphViewController: UIViewController{
    
    var points: [String] = []
    var prices: [Double] = []

    @IBOutlet var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var date = Date(timeInterval: -60*60*24*6, since: Date())//一週間前の日時を取得
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        date = (calender?.startOfDay(for: date))!   //日の始めに合わせる//Optional型注意
        
        let format = DateFormatter()
        format.dateFormat = "dd"
        
        let realm = try! Realm()    //失敗した時のエラー処理が必要
        var items:Results<Item>!
        
        barChartView.animate(yAxisDuration: 2.0)
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = true
        barChartView.xAxis.labelPosition = .bottom
        barChartView.chartDescription?.text = "Money chart"
        
        for i in 0..<7{
            points += [format.string(from: date)]
            items = realm.objects(Item.self).filter(NSPredicate(format: "created BETWEEN {%@,%@}", date as CVarArg, Date(timeInterval: 60*60*24-1, since: date) as CVarArg))//日付ごとにrealmから呼び出し
            prices += [0]
            for j in 0..<items.count{
                prices[i] += Double(items[j].price)
            }
            date = Date(timeInterval: 60*60*24, since: date)
        }
        
        setChart(dataPoints: points, values: prices)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "No Data"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "金額")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.xAxis.valueFormatter = BarChartFormatter(labels: dataPoints)
    }
}

public class BarChartFormatter: NSObject, IAxisValueFormatter{
    var array: [String]!
    
    init(labels:[String]) {
        array = labels
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {//arrayがnilのまま突っ込んだ時の例外処理が必要
        return array[Int(value)]
    }
}
