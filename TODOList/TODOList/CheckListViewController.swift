//
//  ViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/30.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController,AddTaskDelegate {
    
    
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let task1 = Task()
        task1.name = "测试数据"
//        let task2 = Task()
//        task1.name = "测试数据"
//        let task3 = Task()
//        task1.name = "测试数据"
        
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
        tasks.append(task1)
    }
    

    //代理模式 代理addTaskViewController 实现此方法 进行值传递
    func addTaskViewController(controller: AddTaskViewController, didFinishAddTask task: Task) {
        //此时数据已经添加成功 但是tableview数据没有刷新
        tasks.append(task)
        
        //将数据添加到特定的位置 只刷新需要刷新的部位
        let indexPath = NSIndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
        
        //简单粗暴 会重新加载下面两个函数
        //tableView.reloadData()
    }
    
    
    //获取总条数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //获取每条的内容并显示   IndexPath 两个属性 row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCell
        let task = tasks[indexPath.row]

        cell.customLabel.text = task.name
        cell.customLabel.textColor = UIColor.red
        
        let checkMarkLabel = cell.viewWithTag(1001) as! UILabel
        if task.isCheck {
            checkMarkLabel.text = "√"
        }else{
            checkMarkLabel.text = ""
        }
        
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
        if indexPath.row != 0 {
            return true
        } else {
            return false
        }
    }
    //删除任务
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //将 CheckListViewController对象 传递给 AddTaskViewController 因为navigationVC 目前只有一个ViewController 所以直接使用navigationVC.topViewController 就可以获取到ß
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationVC = segue.destination as! UINavigationController
        let addTaskVC = navigationVC.topViewController as! AddTaskViewController
        
        if segue.identifier == "addTask"{
            addTaskVC.addTaskDelegate = self
        } else if segue.identifier == "editTask"{
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            if let indexPath = indexPath {
                let task = tasks[indexPath.row]
                addTaskVC.taskToEdit = task
            }
            
        }
    }

}

