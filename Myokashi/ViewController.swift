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
    
    tableView.dataSource = self
    
    tableView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var seachText: UISearchBar!

  @IBOutlet weak var tableView: UITableView!
  //タプル
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
  
  func searchOkashi(keyword : String){

    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
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
        
      
  //      print("count = \(String(describing: json["count"]))")
        
        if let items = json["item"] as? [[String:Any]] {
          
          for item in items {
            
            guard let maker = item["maker"] as? String else {
              continue
            }
            guard let name = item["name"] as? String else {
              continue
            }

            guard let link = item["url"] as? String else {
             continue
            }
            guard let image = item["image"] as? String else {
              continue
            }
            
            let okashi = (maker,name,link,image)
            self.okashiList.append(okashi)
            
          }
        }
        
        print("--------------")
        print("okashiList[0] = \(String(describing: self.okashiList.first))")
        
        self.tableView.reloadData()
        
      } catch{
       print("エラーが発生しました")
      
      }}
    )
  task.resume()
    
    
    }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashicell", for: indexPath)
    
    cell.textLabel?.text = okashiList[indexPath.row].name
  
    let url = URL(string: okashiList[indexPath.row].image)
    
    if let image_date = try? Data(contentsOf: url!){
    
    cell.imageView?.image = UIImage(data: image_date)
    }
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






