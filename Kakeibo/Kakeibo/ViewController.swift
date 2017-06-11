import UIKit
import RealmSwift

class ViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource{
    
  
    @IBOutlet weak var RegistButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var myDate: UITextField!
    @IBOutlet weak var myName: UITextField!
    @IBOutlet weak var myPrice: UITextField!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var viewSource: UILabel!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    
    let editDate: UITextField = UITextField()
    let editName: UITextField = UITextField()
    let editPrice: UITextField = UITextField()
    
    var edit = Date()
    
    private var myToolbar: UIToolbar!
    var year = 0;
    var month = 0;
    
    var ItemList: Results<Item>!
    var alertTmp: UIAlertController = UIAlertController(title: "編集", message: "編集値を入力してください", preferredStyle:  UIAlertControllerStyle.alert)
    
    var tmp = Item()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //時間獲得
        myDate.text = getNowClockString()
        changeViewSource()
        
        //Realmを取得
        let realm = try! Realm()
        self.ItemList = realm.objects(Item.self).filter("month == %@", month).sorted(byKeyPath: "created", ascending: false)
        myTable.reloadData()
        
        //TextField 設定
        
        
        myDate.delegate = self
        myName.delegate = self
        myName.placeholder = "品名"
        myPrice.placeholder = "金額"
        
        //キーボードを数値のみに制限
        myPrice.keyboardType = UIKeyboardType.numberPad
        
        
        //ToolBar 設定 
        //DatePicker,textfield上のToolBarボタン
        myToolbar = UIToolbar()
        myToolbar.sizeToFit()
        let ToolBarButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(ViewController.done))
        let ToolBarSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let ToolBarButton2 = UIBarButtonItem(title: "登録", style: .plain, target: self, action: #selector(Regist(_:)))
        myToolbar.items = [ToolBarButton,ToolBarSpace,ToolBarButton2]
        myName.inputAccessoryView = myToolbar
        myDate.inputAccessoryView = myToolbar
        myPrice.inputAccessoryView = myToolbar
        
    }
    
    
    @IBAction func Regist(_ sender: Any) {
        
        let item = Item()
        item.name = self.myName.text
        
        var now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        item.created = dateFormatter.date(from: self.myDate.text!)!
        now = dateFormatter.date(from: self.myDate.text!)!
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        
        item.year = Int(yearFormatter.string(from: now))!
        item.month = Int(monthFormatter.string(from: now))!
        item.day = Int(dayFormatter.string(from: now))!
        
        //item.month = Int(monthFormatter.string(from: item.created))!
        
        
        // インサート実行
        if self.myPrice.text != "" {
            item.price = Int(self.myPrice.text!)!
            let realm = try! Realm()
            try! realm.write {
                realm.add(item)
                print("did save")
                myName.text = ""
                myPrice.text = ""
            }
        } else {
            let alert: UIAlertController = UIAlertController(title: "入力エラー", message: "金額を入力してください", preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
        
        done()
        print("button")
        print(item.name!)
        
        //テーブルを再読込
        self.myTable.reloadData()
        
    }
    
    //全削除
    @IBAction func Delete(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "警告", message: "データをすべて削除します。\nよろしいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                print("did delete")
            }
            self.myTable.reloadData()
            
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        // キーボードを閉じる
        myName.resignFirstResponder()
        
        return true
    }
    
    //時間獲得
    func getNowClockString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        
        let now = Date()
        
        year = Int(yearFormatter.string(from: now))!
        month = Int(monthFormatter.string(from: now))!
        
        return formatter.string(from: now)
    }
    
    //DatePickerが選ばれた際に呼ばれる.
    internal func onDidChangeDate(sender: UIDatePicker){
        
        // フォーマットを生成.
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy年MM月dd日"
        
        // 日付をフォーマットに則って取得.
        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
        
        myDate.text = mySelectedDate as String
        
        
        //DatePickerの変化により、TableViewに表示されるデータを変更
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        
        
        var set = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        set = dateFormatter.date(from: self.myDate.text!)!
        
        year = Int(yearFormatter.string(from: set))!
        month = Int(monthFormatter.string(from: set))!
        
        changeViewSource()
        doReload()
    }
    
    //テキストフィールド選択時、DatePicker表示
    func textFieldShouldBeginEditing(_ myDate: UITextField) -> Bool {
        // DatePickerを生成する.
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDate.inputView = myDatePicker
        myName.inputView = nil
        
        // datePickerを設定（デフォルトでは位置は画面上部）する.
        myDatePicker.frame = CGRect(x:0, y:420, width:self.view.frame.width, height:250)
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.backgroundColor = UIColor.white
        myDatePicker.layer.cornerRadius = 5.0
        myDatePicker.datePickerMode = UIDatePickerMode.date
        
        
        //テキストフィールドの値をDatePickerに反映
        var set = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        set = dateFormatter.date(from: self.myDate.text!)!
        
        myDatePicker.setDate(set, animated: true)
        
        
        // 値が変わった際のイベントを登録する.
        myDatePicker.addTarget(self, action: #selector(ViewController.onDidChangeDate(sender:)), for: .valueChanged)
        return true
    }
    
    //金額表示用に変換
    private func convert(price: Int) -> String
    {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = NumberFormatter.Style.decimal
        decimalFormatter.groupingSeparator = ","
        decimalFormatter.groupingSize = 3
        return "¥"+decimalFormatter.string(from: price as NSNumber)!
    }
    
    //tableView関連
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ItemList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell: ListCell = tableView.dequeueReusableCell(withIdentifier: "ListCell")! as! ListCell
        
        // 行取得
        let item: Item = self.ItemList[(indexPath as NSIndexPath).row];
        // 品名
        cell.CellName.text = item.name
        // 金額
        cell.CellPrice.text = self.convert(price: item.price)
        // 登録日時
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        cell.CellDate.text = formatter.string(from: item.created)
        
        return cell
    }
    
    func changeDate(sender: UIDatePicker){
        
        
        // フォーマットを生成.
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy年MM月dd日"
        
        // 日付をフォーマットに則って取得.
        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
        
        self.alertTmp.textFields![0].text = mySelectedDate as String
        
    }
    
    func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        print("IndexPath: \(indexPath.row)")
        print("Value: \(ItemList[indexPath.row])")
        print("Edeintg: \(table.isEditing)")
        
        tmp = self.ItemList[indexPath.row]
        
        
        let alert: UIAlertController = UIAlertController(title: "編集", message: "編集値を入力してください", preferredStyle:  UIAlertControllerStyle.alert)
        self.alertTmp = alert
        
        let edit = UIAlertAction(title: "アクション１", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            
            self.editDate.text = alert.textFields![0].text
            self.editName.text = alert.textFields![1].text
            self.editPrice.text = alert.textFields![2].text
            
            
            self.addcell(_tmp: self.tmp)
            print(self.editDate)
        })
        
        alert.addAction(edit)
        
        
        
        
        alert.addTextField(configurationHandler: {(editDate) -> Void in
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            
            // DatePickerを生成する.
            let myDatePicker: UIDatePicker = UIDatePicker()
            editDate.inputView = myDatePicker
            
            
            // datePickerを設定（デフォルトでは位置は画面上部）する.
            myDatePicker.frame = CGRect(x:0, y:420, width:self.view.frame.width, height:250)
            myDatePicker.timeZone = NSTimeZone.local
            myDatePicker.backgroundColor = UIColor.white
            myDatePicker.layer.cornerRadius = 5.0
            myDatePicker.datePickerMode = UIDatePickerMode.date
                
                
            //テキストフィールドの値をDatePickerに反映
            var set = Date()
                
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            set = self.ItemList[indexPath.row].created
            
            myDatePicker.setDate(set, animated: true)
            
            
            // 値が変わった際のイベントを登録する.
            myDatePicker.addTarget(self, action: #selector(ViewController.changeDate(sender:)), for: .valueChanged)
            
                
 
            editDate.text = formatter.string(from: self.ItemList[indexPath.row].created)
            self.edit = self.ItemList[indexPath.row].created
            let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
            label.text = "登録日"
            editDate.leftView = label
            editDate.leftViewMode = UITextFieldViewMode.always
            
            
        })
        alert.addTextField(configurationHandler: {(editName) -> Void in
            editName.text = self.ItemList[indexPath.row].name
            let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
            label.text = "品名"
            editName.leftView = label
            editName.leftViewMode = UITextFieldViewMode.always
            editName.inputAccessoryView = self.myToolbar
        })
        alert.addTextField(configurationHandler: {(editPrice) -> Void in
            editPrice.text = String(self.ItemList[indexPath.row].price)
            let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
            label.text = "金額"
            editPrice.leftView = label
            editPrice.leftViewMode = UITextFieldViewMode.always
            editPrice.keyboardType = UIKeyboardType.numberPad
        })
        present(alert, animated: true, completion: nil)
    }
    
    // TableViewのCellの削除を行った際に、Realmに保存したデータを削除する
    func tableView(_ table: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            do{
                let realm = try Realm()
                try realm.write {
                    realm.delete(self.ItemList[indexPath.row])
                }
                table.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }catch{
            }
            table.reloadData()
        }
    }
  
    func done(){
        myName.resignFirstResponder()
        myDate.resignFirstResponder()
        myPrice.resignFirstResponder()
    }
  
    func changeViewSource(){
        
        viewSource.text = "\(year)年\(month)月"
    }
    
    func doReload(){
        let realm = try! Realm()
        self.ItemList = realm.objects(Item.self).filter("month == %@", month).sorted(byKeyPath: "created", ascending: false)
        self.myTable.reloadData()

    }
    
    @IBAction func next(_ sender: Any) {
        if month < 12 {
            month += 1
        } else {
            year += 1
            month = 1
        }
        changeViewSource()
        doReload()
    }
    
    @IBAction func previous(_ sender: Any) {
        if month > 1 {
            month -= 1
        } else {
            year -= 1
            month = 12
        }
        changeViewSource()
        doReload()
    }
    
    func editDate(sender: UIDatePicker){
        
        print("ok")
        
         /*フォーマットを生成.
         let myDateFormatter: DateFormatter = DateFormatter()
         myDateFormatter.dateFormat = "yyyy年MM月dd日"
         
         // 日付をフォーマットに則って取得.
         let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
         
        
        */
        
    }
    
    
    func addcell(_tmp:Item){
        
        /*tmp.name = self.editName.text
        //tmp.price = Int(self.editPrice.text!)!
        let realm = try! Realm()
        try! realm.write {
            realm.add(tmp)
            print("did save")
        }
 */
        
        
        let realm = try! Realm()
        try! realm.write {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            tmp.created = dateFormatter.date(from: self.editDate.text!)!
            
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MM"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"

            var now = Date()
            now = dateFormatter.date(from: self.editDate.text!)!
            tmp.year = Int(yearFormatter.string(from: now))!
            tmp.month = Int(monthFormatter.string(from: now))!
            tmp.day = Int(dayFormatter.string(from: now))!

            
            tmp.name = editName.text
            tmp.price = Int(editPrice.text!)!
            
        }
        myTable.reloadData()
        print(tmp)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
