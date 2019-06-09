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
        
        let tc1 = TaskCategory(name: "工作")
        taskCategories.append(tc1)
        
        let tc2 = TaskCategory(name: "学习")
        taskCategories.append(tc2)
        
        let tc3 = TaskCategory(name: "娱乐")
        taskCategories.append(tc3)
    }

    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController, didFinishAddTaskCategory taskCategory: TaskCategory) {
        taskCategories.append(taskCategory)
        tableView.reloadData()
    }
    
    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController, didFinishEditTaskCategory taskCategory: TaskCategory) {
        taskCategories.append(taskCategory)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskCategories.count
    }
    
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
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "taskCategoryDetailNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! TaskCategoryDetailViewController
        let taskCagegory = taskCategories[indexPath.row]
        controller.taskCategoryToEdit = taskCagegory
        controller.taskCategoryDetailDelegate = self
        taskCategories.remove(at: indexPath.row)
        present(navigationController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let taskCategory = taskCategories[indexPath.row]
        performSegue(withIdentifier: "showTasks", sender: taskCategory)
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
}
