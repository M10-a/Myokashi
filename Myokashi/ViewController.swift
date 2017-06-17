//
//  ViewController.swift
//  Myokashi
//
//  Created by 浅野未央 on 2017/06/17.
//  Copyright © 2017年 mio. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController,UISearchBarDelegate, UITableViewDataSource , UITableViewDelegate ,SFSafariViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    //SearchBarのdelegate通知先を設定
    seachText.delegate = self
    //入力のヒントになるブレースホルダを指定
    seachText.placeholder = "お菓子の名前を入力してください"
    // tableViewのdataSourceを設定
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var seachText: UISearchBar!

  @IBOutlet weak var tableView: UITableView!
  //お菓子のリスト　タプル配列
  var okashiList : [(maker:String , name:String , link:String , image:String)] = []
  
  // サーチボタンクリック時
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //キーボードを閉じる
    view.endEditing(true)
    //ディバックエリアに出力
    print(searchBar.text ?? "値がありません")
    if let saechWord = seachText.text{
      searchOkashi(keyword: saechWord)
    }
  }
 //searchOkashiメゾット
 //第一引数：キーワード検索したいワード
  func searchOkashi(keyword : String){
 //お菓子の検索キーワードをURLエンコードする
    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
//URLオブジェクトの形成
    let url = URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode!)&max=10&order=r")
   
    print(url ?? "値がありません")
    
    let req = URLRequest(url: url!)
    
    let configuration = URLSessionConfiguration.default
    
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    //メインスレッドで動かす
    let task = session.dataTask(with: req, completionHandler: {
    (date , request , error) in
    
      do{
        let json = try JSONSerialization.jsonObject(with: date!) as! [String:Any]
        
        self .okashiList.removeAll()
        
      
      //print("count = \(String(describing: json["count"]))")
       
         // お菓子の情報が取得できているか確認
        if let items = json["item"] as? [[String:Any]] {
           //取得しているお菓子の数だけ処理
          for item in items {
            //メーカー名
            guard let maker = item["maker"] as? String else {
              continue
            }
            //お菓子の名称
            guard let name = item["name"] as? String else {
              continue
            }
            //掲載URL
            guard let link = item["url"] as? String else {
             continue
            //画像URL
            }
            guard let image = item["image"] as? String else {
              continue
            }
            
            //１つのお菓子をタプルでまとめて管理
            let okashi = (maker,name,link,image)
            //お菓子の配列へ追加
            self.okashiList.append(okashi)
            
          }
        }
        
        print("--------------")
        print("okashiList[0] = \(String(describing: self.okashiList.first))")
        
        self.tableView.reloadData()
        
      } catch{
        //エラー処理
       print("エラーが発生しました")
      
      }}
    )
  task.resume()
    
    
    }
  //cellの総数を渡すdetasourceメゾット。必ず記載する
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //今回表示を行うcellオブジェクトを取得する
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashicell", for: indexPath)
    
    //お菓子のタイトル設定
    cell.textLabel?.text = okashiList[indexPath.row].name
    //お菓子の画像URLを取り出す
    let url = URL(string: okashiList[indexPath.row].image)
    //URLから画像を取得
    if let image_date = try? Data(contentsOf: url!){
    //正常にできた場合はUIImageで画像オブジェクトを生成してcellにお菓子画像を設定
    cell.imageView?.image = UIImage(data: image_date)
    }
    //設定済みのcellオブジェクトを画面に反映
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let urlToLink = URL(string: okashiList[indexPath.row].link)
    
    let safariViewController = SFSafariViewController(url: urlToLink!)
    
    safariViewController.delegate = self
    
    present(safariViewController, animated: true, completion:  nil)
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController){
    dismiss(animated: true, completion: nil)
    }
  }
  }






