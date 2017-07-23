//
//  CalendarViewController.swift
//  Kakeibo
//
//  Created by 関澤春香 on 2017/07/20.
//  Copyright © 2017年 Wittgenstein. All rights reserved.
//

import UIKit
import RealmSwift

class CalendarViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout ,  UITableViewDelegate, UITableViewDataSource{
    //曜日設定
    let weekArray = ["日", "月", "火", "水", "木", "金", "土"]
    //前次月確認
    let tukiArray = ["前月", "次月","",""]
    
    let numOfDays = 7  //
    let cellMargin : CGFloat = 2.0  //
    var secIndexPath: IndexPath! // path格納宣言

    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var myTableView: UITableView!


    //DateManager.swift
    let dateManager = DateManager()
    
    //Realmを取得
    let realm = try! Realm()
    // Realmに保存されてるItem型のオブジェクトを全て取得
    var items:Results<Item>!
    var prices: Double = 0
    var total: Int = 0
    //var datalist: [String] = []
    var datalist = ["", "", "", "", "", "", "", "", "", ""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myTableView.dataSource = self    //追加
        myTableView.delegate = self // 追加
        
        headerTitle.text = dateManager.CalendarHeader()
        
        
        //Realmを取得
        //let realm = try! Realm()
        
        // Realmに保存されてるItem型のオブジェクトを全て取得
        //let item = realm.objects(Item)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Sectionの数
     */
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    /*
     Cellが選択された際に呼び出される
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Num: \(indexPath.row)")
        print("SectionNum:\(indexPath.section)")
        
        
        
        //押した時、色変更
        if case indexPath.section = 1{
            print("Push!")
            secIndexPath = indexPath
            //更新
            collectionView.reloadData()
        }
        
    }
    
    
    
    
    /*
     Cellの総数を返す
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Section毎にCellの総数を変える.
        if(section == 0){   //section:0は曜日を表示
            return numOfDays
        }else{
            return dateManager.daysAcquisition() //section:1は日付を表示 　今の時点では適当な数字30日くらいなので30を入れる
        }
        
        
    }
    
    
    /*
     Sectionに値を設定する
     */
    //    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Section", for: indexPath)
    //
    //        headerView.backgroundColor = UIColor.white
    //
    //        return headerView
    //    }
    
    /*
     Cellに値を設定する
     */
    //データを返すメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //コレクションビューから識別子「CalendarCell」のセルを取得する
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath) as! CustomUICollectionViewCell
        if(indexPath.section == 0){             //曜日表示
            //cell.backgroundColor = UIColor.green
            cell.backgroundColor = UIColor(red: 152/255, green: 216/255, blue: 186/255, alpha: 1.0)
            cell.textLabel?.text = weekArray[indexPath.row]
            
        }else{                                  //日付表示
            cell.backgroundColor = UIColor.white
            //選択時の処理
            if (secIndexPath != nil){
                if (indexPath == secIndexPath){
                    cell.backgroundColor = UIColor(red: 255/255, green: 194/255, blue: 164/255, alpha: 1.0)
                    /////////////////////////////////////////
                    var setDay = dateManager.itemDate(index: indexPath.row) //日にち取得
                    items = realm.objects(Item.self).filter("created == %@", setDay)
                    for k in 0...indexPath.row{
                        for j in 0..<items.count{
                            if(items[j].name != nil){
                                datalist[j] = items[j].name!
                            }else{
                                datalist[j] = ""
                            }
                        }

                    }
                    /////////////////////////////////////////
                }
            }

            //合計取得
            var setDay = dateManager.itemDate(index: indexPath.row) //日にち取得
            items = realm.objects(Item.self).filter("created == %@", setDay)
            
            for k in 0...indexPath.row{
                total = 0
                prices = 0
                for j in 0..<items.count{
                    prices += Double(items[j].price)
                    total = total + items[j].price
                }
                if(total == 0){
                    cell.textLabel?.text = dateManager.conversionDateFormat(index: indexPath.row) +  "\n" //Index番号から表示する日を求める
                }else{
                    cell.textLabel?.text = dateManager.conversionDateFormat(index: indexPath.row) + "\n"+String(total)
                }
            }
        }
        return cell
    }
    
    
    /*
     
     セルのレイアウト設定
     
     */
    //セルサイズの指定（UICollectionViewDelegateFlowLayoutで必須）　横幅いっぱいにセルが広がるようにしたい
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfMargin:CGFloat = 8.0
        let widths:CGFloat = (collectionView.frame.size.width - cellMargin * numberOfMargin)/CGFloat(numOfDays)
        let heights:CGFloat = widths * 0.8
        
        return CGSize(width:widths,height:heights)
    }
    
    //セルのアイテムのマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0 , 0.0 , 0.0 , 0.0 )  //マージン(top , left , bottom , right)
    }
    
    //セルの水平方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellMargin
    }
    //セルの垂直方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellMargin
}

    @IBAction func nextMonthBtn(_ sender: UIButton) {
        dateManager.nextMonthCalendar()
        myCollectionView.reloadData()
        headerTitle.text = dateManager.CalendarHeader()
    }
    @IBAction func prevMonthBtn(_ sender: UIButton) {
        dateManager.preMonthCalendar()
        myCollectionView.reloadData()
        headerTitle.text = dateManager.CalendarHeader()
    }


    /*
     
     TableView
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 一つのsectionの中に入れるCellの数を決める。
        
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの内容を決める（超重要）
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "tableCell")
        //cell.textLabel?.text = "swift"
        cell.textLabel?.text = datalist[indexPath.row]
        
        return cell
        
    }
    
}
