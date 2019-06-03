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

    let addTask = "addTask"
    let editTask = "editTask"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //TODO
        let airplane = Task("飞机")
        let car = Task("汽车")
        let train = Task("火车")
        
        tasks.append(airplane)
        tasks.append(car)
        tasks.append(train)
//        for i in 1...10{
//            task1.name = "测试数据" + "\(i)"
//            print("\(i)")
//            tasks.append(task1)
//        }
    
    }
    

    //代理模式 代理addTaskViewController 实现此方法 进行值传递
    func taskDetailViewController(controller: TaskDetailViewController, didFinishAddTask task: Task) {
        //此时数据已经添加成功 但是tableview数据没有刷新
        tasks.append(task)
        
        //将数据添加到特定的位置 只刷新需要刷新的部位
        let indexPath = NSIndexPath(row: tasks.count - 1, section: 0)
        self.tableView.beginUpdates()
        tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
        self.tableView.endUpdates()
        
        //简单粗暴 会重新加载下面两个函数
        //tableView.reloadData()
    }
    
    
    func taskDetailViewController(controller: TaskDetailViewController, didFinishEditTask task: Task) {
        let index = tasks.firstIndex(of: task)
        if let index = index {
            let indexPath = NSIndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! CustomCell
            configCell(cell: cell , task:task)
        }
    }
    
    //获取总条数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //获取每条的内容并显示   IndexPath 两个属性 row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let task = tasks[indexPath.row]

        configCell(cell: cell, task:task)
        return cell
    }

    //判断是否选择
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //找到被选中的这一行
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        
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
    }
    //不允许删除第一行
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    //删除任务
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableView.beginUpdates()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    //将 CheckListViewController对象 传递给 AddTaskViewController 因为navigationVC 目前只有一个ViewController 所以直接使用navigationVC.topViewController 就可以获取到
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationVC = segue.destination as! UINavigationController
        let addTaskVC = navigationVC.topViewController as! TaskDetailViewController
        
        if segue.identifier == addTask {
            addTaskVC.taskDetailDelegate = self
        } else if segue.identifier == editTask {
            addTaskVC.taskDetailDelegate = self
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            if let indexPath = indexPath {
                let task = tasks[indexPath.row]
                addTaskVC.taskToEdit = task
            }
        }
    }
    
    func configCell(cell: CustomCell, task: Task) {
        cell.customLabel.text = task.name
        cell.customLabel.textColor = UIColor.red
        
        let checkMarkLabel = cell.viewWithTag(1001) as! UILabel
        if task.isCheck {
            checkMarkLabel.text = "√"
        }else{
            checkMarkLabel.text = ""
        }
    }
}

