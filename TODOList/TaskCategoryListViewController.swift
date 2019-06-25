 //
//  ListCategoryViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/6/8.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

 class TaskCategoryListViewController: UITableViewController{
    
    var taskCategories = [TaskCategory]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTaskCategoryList()
   //     loadTodayWeather()
    }
    
    func deleteDataFromTaskCategories(taskCategory: TaskCategory) {
        let checkIndex = taskCategories.firstIndex(where: { (item) -> Bool in
            taskCategory.name == item.name
        })
        guard let index = checkIndex else {
            return
        }
        taskCategories.remove(at: index)
    }

    //获取保存路径
    func dataFilePath() -> [String] {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = paths[0] as NSString
        return filePath.strings(byAppendingPaths: ["TaskCategoryList.json"])
    }
    
    //将添加或修改的数据写入到文件中
    func saveTaskCategoryList() {
        do{
            let jsonData = try JSONEncoder().encode(taskCategories)
            let jsonString = String(decoding: jsonData, as: UTF8.self) as NSString
            try jsonString.write(toFile: dataFilePath()[0], atomically: true, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //从文件中读取数据
    func loadTaskCategoryList() {
        if let readData = try? String(contentsOfFile: dataFilePath()[0]).data(using: .utf8) {
            do {
                if let taskCategory = try? JSONDecoder().decode([TaskCategory].self,from: readData) {
                    taskCategories.append(contentsOf: taskCategory)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //请求天气接口，获取数据并展示
    func loadTodayWeather() {
        AF.request("https://v.juhe.cn/weather/index", parameters: ["cityname": "西安","dtype": "json","format": "1","key":"ea22e4069a5398a36a31616eca5fccca"])
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    let json = JSON.init(value)
                    let city = json["result"]["today"]["city"].stringValue
                    let date = json["result"]["today"]["date_y"].stringValue
                    let week = json["result"]["today"]["week"].stringValue
                    let weather = json["result"]["today"]["weather"].stringValue
                    let wind = json["result"]["today"]["wind"].stringValue
                    self.showWeather(city: city, date: date, week: week, weather: weather, wind: wind)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //显示天气数据
    func showWeather(city: String, date: String, week: String, weather: String, wind: String) {
        let result = city + " " + date + " " + week + " \n" + weather + " " + wind
        let alert = UIAlertController(title: "天气", message: result, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "返回", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {
            ACTION in
            print(result)
        })

        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

 extension TaskCategoryListViewController {
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskCategories.count
    }
    
    //手动实现创建cell并初始化
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .detailDisclosureButton
        }
        let tc = taskCategories[indexPath.row]
        cell?.textLabel?.text = tc.name
        return cell!
    }
    
    //手动实现获取navigation以及它管理的controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "taskCategoryDetailNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! TaskCategoryDetailViewController
        
        let taskCagegory = taskCategories[indexPath.row]
        controller.taskCategoryToEdit = taskCagegory
        controller.taskCategoryDetailDelegate = self
        present(navigationController, animated: true, completion: nil)
    }
    
    //任务分类显示内容
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let taskCategory = taskCategories[indexPath.row]
        performSegue(withIdentifier: "showTasks", sender: taskCategory)
    }
    
    //删除任务
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableView.beginUpdates()
        let taskCategory = taskCategories[indexPath.row]
        deleteDataFromTaskCategories(taskCategory: taskCategory)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        saveTaskCategoryList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTasks" {
            let taskListVC = segue.destination as! TaskListViewController
            taskListVC.taskCategory = (sender as! TaskCategory)
        } else if segue.identifier == "addTaskCategory" {
            let navigation = segue.destination as! UINavigationController
            let tcDetail = navigation.visibleViewController as! TaskCategoryDetailViewController
            tcDetail.taskCategoryDetailDelegate = self
        }
    }
 }

extension TaskCategoryListViewController: TaskCategoryDetailDelegate {
    
    func taskCategoryDetailAdd(didFinishAddTaskCategory taskCategory: TaskCategory) {
        taskCategories.append(taskCategory)
        saveTaskCategoryList()
        tableView.reloadData()
    }
    
    func taskCategoryDetailEdit(didFinishEditTaskCategory taskCategory: TaskCategory, shouldDeleteCategoty oldCategory: TaskCategory) {
        deleteDataFromTaskCategories(taskCategory: oldCategory)
        taskCategories.append(taskCategory)
        saveTaskCategoryList()
        tableView.reloadData()
    }
 }
