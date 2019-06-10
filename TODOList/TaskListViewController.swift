//
//  ViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/30.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit
class TaskListViewController: UITableViewController,TaskDetailDelegate {
    
    var tasks = [Task]()
    var dataSource = [Task]()
    var taskCategory: TaskCategory!
    
    let addTaskSegueIdentifier = "addTask"
    let editTaskSegueIdentifier = "editTask"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = taskCategory.name
        loadTaskList()
        taskByCategory(taskCategory: taskCategory)
    }
    
    func taskByCategory(taskCategory: TaskCategory) {
        for task in tasks {
            if task.taskCategory.isEqual(taskCategory.name) {
                dataSource.append(task)
            }
        }
    }
    
    //代理模式 代理addTaskViewController 实现此方法 进行值传递
    func taskDetailViewController(controller: TaskDetailViewController, didFinishAddTask task: Task) {
        //此时数据已经添加成功 但是tableview数据没有刷新
        tasks.append(task)
        dataSource.append(task)
        tableView.reloadData()
        //保存文件
        saveTaskList()
    }
    
    func taskDetailViewController(controller: TaskDetailViewController, didFinishEditTask task: Task) {
        tasks.append(task)
        dataSource.append(task)
        tableView.reloadData()
        saveTaskList()
    }
    
    //获取总条数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    //获取每条的内容并显示   IndexPath 两个属性 row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let task = dataSource[indexPath.row]
        configCell(cell: cell, task:task)
        return cell
    }
    
    //判断是否选择
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //取消选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        
        var task = dataSource[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
//        let checkMarkLabel = cell.checkMarkLabel!
//
//        if let cell = tableView.cellForRow(at: indexPath){
//            if checkMarkLabel.text == "√"{
//                checkMarkLabel.text = ""
//                task.isCheck = false
//            }else{
//                checkMarkLabel.text = "√"
//                task.isCheck = true
//            }
//        }
        if let cell = tableView.cellForRow(at: indexPath){
            //找到Tag为1001的 Label
            let checkMarkLabel = cell.viewWithTag(1001) as! UILabel
            if checkMarkLabel.text == "√"{
                checkMarkLabel.text = ""
                task.isCheck = false
            }else{
                checkMarkLabel.text = "√"
                task.isCheck = true
            }
        }
        saveTaskList()
    }
    
    //不允许删除第一行
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func deleteDataFromTasks(task: Task) -> Int{
        var num = 0
        var index = 0
        for data in tasks {
            if data.name == task.name {
                index = num
            }
            num += 1
        }
        return index
    }
    
    //删除任务
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableView.beginUpdates()
        tableView.reloadData()
        let task = dataSource[indexPath.row]
        let index = deleteDataFromTasks(task: task)
        tasks.remove(at: index)
        dataSource.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        saveTaskList()
    }
    
    //将 TaskListViewController对象 传递给 TaskDetailViewController 因为navigationVC 目前只有一个ViewController 所以直接使用navigationVC.topViewController 就可以获取到
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationVC = segue.destination as! UINavigationController
        let taskDetailVC = navigationVC.topViewController as! TaskDetailViewController
        taskDetailVC.taskCategory = taskCategory
        if segue.identifier == addTaskSegueIdentifier {
            taskDetailVC.taskDetailDelegate = self
        } else if segue.identifier == editTaskSegueIdentifier {
            taskDetailVC.taskDetailDelegate = self
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            if let indexPath = indexPath {
                //将要修改的内容传递给修改页面，并将原内容删除
                let task = dataSource[indexPath.row]
                taskDetailVC.taskToEdit = task
                dataSource.remove(at: indexPath.row)
                let index = deleteDataFromTasks(task: task)
                tasks.remove(at: index)
            }
        }
    }
    
    func configCell(cell: CustomCell, task: Task) {
        cell.customLabel.text = task.name
        cell.customLabel.textColor = UIColor.red
        
        let checkMarkLabel = cell.checkMarkLabel!
        if task.isCheck {
            checkMarkLabel.text = "√"
        }else{
            checkMarkLabel.text = ""
        }
    }
    
    func dataFilePath() -> [String] {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = paths[0] as NSString
        return filePath.strings(byAppendingPaths: ["TaskList.json"])
    }
    
    //将添加或修改的数据写入到文件中
    func saveTaskList() {
        do{
            let jsonData = try JSONEncoder().encode(tasks)
            let jsonString = String(decoding: jsonData, as: UTF8.self) as NSString
            try jsonString.write(toFile: dataFilePath()[0], atomically: true, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //从文件中读取数据
    func loadTaskList() {
        if let readData = try? String(contentsOfFile: dataFilePath()[0]).data(using: .utf8) {
            do {
                print(dataFilePath()[0])
                if let task = try? JSONDecoder().decode([Task].self,from: readData) {
                    tasks.append(contentsOf: task)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

