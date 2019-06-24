//
//  ViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/30.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit
class TaskListViewController: UITableViewController {
    
    var tasks = [Task]()
    var dataSource = [Task]()
    var taskCategory: TaskCategory!
    
    let addTaskSegueIdentifier = "addTask"
    let editTaskSegueIdentifier = "editTask"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME
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
    
    func deleteDataFromTasks(task: Task) {
        let checkIndex = tasks.firstIndex(where: { (item) -> Bool in
              task.name == item.name
        })
        guard let index = checkIndex else {
            return
        }
        tasks.remove(at: index)
    }
    
    func deleteDataFromDataSource(task: Task) {
        let checkIndex = dataSource.firstIndex(where: { (item) -> Bool in
            task.name == item.name
        })
        guard let index = checkIndex else {
            return
        }
        dataSource.remove(at: index)
    }
    
    //将 TaskListViewController对象 传递给 TaskDetailViewController 因为navigationVC 目前只有一个ViewController 所以直接使用navigationVC.topViewController 就可以获取到
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationVC = segue.destination as! UINavigationController
        let taskDetailVC = navigationVC.visibleViewController as! TaskDetailViewController
        
        taskDetailVC.taskCategory = taskCategory
        if segue.identifier == addTaskSegueIdentifier {
            taskDetailVC.taskDetailDelegate = self
        } else if segue.identifier == editTaskSegueIdentifier {
            taskDetailVC.taskDetailDelegate = self
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            if let indexPath = indexPath {
                //将要修改的内容传递给修改页面
                let task = dataSource[indexPath.row]
                taskDetailVC.taskToEdit = task
            }
        }
    }
    
    //获取保存路径
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

extension TaskListViewController {
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
        checkOrUncheckTask(indexPath.row)
        tableView.reloadData()
        saveTaskList()
    }
    
    //不允许删除第一行
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    //删除任务
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableView.beginUpdates()
        tableView.reloadData()
        let task = dataSource[indexPath.row]
        deleteDataFromTasks(task: task)
        deleteDataFromDataSource(task: task)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        saveTaskList()
    }
    
    func checkOrUncheckTask(_ index: Int) {
        if dataSource[index].isCheck {
            dataSource[index].isCheck = false
        } else {
            dataSource[index].isCheck = true
        }
    }
    
    func configCell(cell: CustomCell, task: Task) {
        cell.customLabel.text = task.name
        cell.customLabel.textColor = UIColor.red
        
        if task.isCheck {
            cell.checkMarkLabel.text = "√"
        }else{
            cell.checkMarkLabel.text = ""
        }
    }
}

extension TaskListViewController: TaskDetailDelegate {
    
    //代理模式 代理addTaskViewController 实现此方法 进行值传递

    func taskDetailAdd(didFinishAddTask task: Task) {
        //此时数据已经添加成功 但是tableview数据没有刷新
        tasks.append(task)
        dataSource.append(task)
        tableView.reloadData()
        //保存文件
        saveTaskList()
    }
    
    func taskDetailEdit(didFinishEditTask task: Task, shouldDeleteTask oldTask: Task) {
        deleteDataFromDataSource(task: oldTask)
        deleteDataFromTasks(task: oldTask)
        tasks.append(task)
        dataSource.append(task)
        tableView.reloadData()
        saveTaskList()
    }
}

