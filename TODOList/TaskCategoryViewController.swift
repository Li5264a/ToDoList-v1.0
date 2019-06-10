 //
//  ListCategoryViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/6/8.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

 class TaskCategoryViewController: UITableViewController,TaskCategoryDetailDelegate {
    
    var taskCategories = [TaskCategory]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTaskCategoryList()
    }

    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController, didFinishAddTaskCategory taskCategory: TaskCategory) {
        taskCategories.append(taskCategory)
        saveTaskCategoryList()
        tableView.reloadData()
    }
    
    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController, didFinishEditTaskCategory taskCategory: TaskCategory) {
        taskCategories.append(taskCategory)
        saveTaskCategoryList()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        taskCategories.remove(at: indexPath.row)
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
        taskCategories.remove(at: indexPath.row)
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
            let tcDetail = navigation.topViewController as! TaskCategoryDetailViewController
            tcDetail.taskCategoryDetailDelegate = self
        }
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
}
