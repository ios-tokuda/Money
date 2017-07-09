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
    var currentdate = Date()
    let averageBar = ChartLimitLine()

    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.animate(yAxisDuration: 2.0)
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = true
        barChartView.xAxis.labelPosition = .bottom
        barChartView.chartDescription?.text = "Money chart"
        barChartView.extraTopOffset = 150.0
        
        barChartView.rightAxis.addLimitLine(averageBar)
        
        showChart(cdate: currentdate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showChart(cdate:Date){
        var points: [String] = []
        var prices: [Double] = []
        var total: Int = 0
        var date = dayStartOfMonth(date: cdate)
        let format = DateFormatter()
        format.dateFormat = "MM"
        
        let realm = try! Realm()    //失敗した時のエラー処理が必要
        var items:Results<Item>!
        
        for i in 0..<5{//1年前
            date = oneMonthAgo(date: date)
        }
        
        label.text = String(dateToYear(date: date)) + "年" + String(dateToMonth(date: date)) + "月〜" + String(dateToYear(date: cdate)) + "年" + String(dateToMonth(date: cdate)) + "月"
        
        for i in 0..<6{
            points += [format.string(from: date)]
            items = realm.objects(Item.self).filter(NSPredicate(format: "created BETWEEN {%@,%@}", date as CVarArg, oneMonthAfter(date: date) as CVarArg))//月ごとにrealmから呼び出し
            prices += [0]
            for j in 0..<items.count{
                prices[i] += Double(items[j].price)
                total = total + items[j].price
            }
            date = oneMonthAfter(date: date)
        }
        
        averageBar.limit = Double(total/6)
        averageBar.label = "月平均="+String(total/6)+"円"
        
        setChart(dataPoints: points, values: prices)
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
    
    
    @IBAction func beforeButton(_ sender: Any) {
        for i in 0..<6{
            currentdate = oneMonthAgo(date: currentdate)
        }
        showChart(cdate: currentdate)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        for i in 0..<6{
            currentdate = oneMonthAfter(date: currentdate)
        }
        showChart(cdate: currentdate)
    }
    
    func oneMonthAgo(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.month = (comp?.month)! - 1
        return (calender?.date(from: comp!))!
    }
    
    func oneMonthAfter(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.month = (comp?.month)! + 1
        return (calender?.date(from: comp!))!
    }
    
    func dayStartOfMonth(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.day = 1
        comp?.hour = 0
        comp?.minute = 0
        comp?.second = 0
        return (calender?.date(from: comp!))!
    }

    func dayStartOfYear(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.month = 1
        comp?.day = 1
        comp?.hour = 0
        comp?.minute = 0
        comp?.second = 0
        return (calender?.date(from: comp!))!
    }
    
    func oneYearAgo(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.year = (comp?.year)! - 1
        return (calender?.date(from: comp!))!
    }
    
    func oneYearAfter(date: Date) -> Date {
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        comp?.year = (comp?.year)! + 1
        return (calender?.date(from: comp!))!
    }
    
    func dateToYear(date:Date) -> Int{
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        return (comp?.year)!
    }
    
    func dateToMonth(date:Date) -> Int{
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: date)
        return (comp?.month)!
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
