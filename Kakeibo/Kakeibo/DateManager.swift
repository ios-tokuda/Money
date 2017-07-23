//
//  DateManager.swift
//  Kakeibo
//
//  Created by 関澤春香 on 2017/07/20.
//  Copyright © 2017年 Wittgenstein. All rights reserved.
//

import UIKit

class DateManager: NSObject {
    var selectDay = Date()
    var biginDay = Date()
    var endDay = Date()
    
    let calendar = Calendar.current
    
    //月カレンダーの始点になる日を求める
    func BeginOfMonthCalender() -> Date{
        
        //日付の要素を1日にする
        var components = calendar.dateComponents([.year,.month,.day], from: selectDay)
        components.day = 1
        let firstOfMonth = Calendar.current.date(from: components)
        
        //曜日を調べて、その要素数だけ戻ったものがカレンダーの左上(日曜日=1 土曜日=7　なので1足した状態で戻る)
        let dayOfWeek = calendar.component(.weekday,from:firstOfMonth!)
        
        return calendar.date(byAdding: .day, value: 1-dayOfWeek, to: firstOfMonth!)!
    }
    
    //月カレンダーの終点になる日を求める
    func EndOfMonthCalendar() ->Date{
        
        //次の月初めを取得
        let nextmonth = calendar.nextDate(after: selectDay, matching: DateComponents(day:1), matchingPolicy: Calendar.MatchingPolicy.nextTime)
        
        //曜日を調べて、その要素数だけ進んだものが右下(次の月の初めで計算している事に注意)
        let dayOfWeek = calendar.component(.weekday,from: nextmonth!)
        
        return calendar.date(byAdding: .day, value: 7-dayOfWeek, to: nextmonth!)!
    }
    
    //月ごとのセルの数を出すメソッド
    func daysAcquisition() -> Int{
        
        //始まりの日と終わりの日を取得
        biginDay = BeginOfMonthCalender()
        endDay = EndOfMonthCalendar()
        
        //始点から終点の日数
        return calendar.dateComponents([.day], from:biginDay ,to:endDay).day! + 1
    }
    
    //カレンダーの始点から指定した日数を加算した日付を返す
    func conversionDateFormat(index: Int)->String{
        
        let currentday = calendar.date(byAdding: .day, value: index, to: biginDay)
        
        return calendar.component(.day, from: currentday!).description
    }
    
    
    //cellの日付情報を取得!!
    func itemDate(index: Int) -> Date{
        let calender = NSCalendar(calendarIdentifier: .gregorian)
        let currentday = calendar.date(byAdding: .day, value: index, to: biginDay)
        var comp = calender?.components([.year,.month,.day,.hour,.minute,.second], from: currentday!)
        return (calender?.date(from: comp!))!
        //return currentday!
        //return calendar.date(byAdding: .day, value: index, to: biginDay)!
    }
    //年取得
    func yearDate(index: Int)->String{
        let currentday = calendar.date(byAdding: .day, value: index, to: biginDay)
        
        return calendar.component(.year, from: currentday!).description
    }
    //月取得
    func monthDate(index: Int)->String{
        let currentday = calendar.date(byAdding: .day, value: index, to: biginDay)
        
        return calendar.component(.month, from: currentday!).description
    }
    
    
    ///////ここから月移動/////////
    //今セレクトされているselectDayの年月をテキストで出力
    func CalendarHeader()->String{
        let formatter = DateFormatter()
        //formatter.dateFormat = "YYYY/MM/dd"
        //入らないからとりあえずこっち
        formatter.dateFormat = "YYYY年MM月"
        
        return formatter.string(from: selectDay)
    }
    
    
    /*
     表示月を変える操作
     */
    
    //SelectDayを一ヶ月戻す
    func preMonthCalendar(){
        selectDay = calendar.date(byAdding: .month, value: -1, to: selectDay)!
    }
    
    //SelectDayを1か月進ませる
    func nextMonthCalendar(){
        selectDay = calendar.date(byAdding: .month, value: 1, to: selectDay)!
    }
    
    
    
}

