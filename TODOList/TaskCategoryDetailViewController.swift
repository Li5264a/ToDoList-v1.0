//
//  TaskCategoryDetailViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/6/9.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit
import UserNotifications

protocol TaskCategoryDetailDelegate: class {
    func taskCategoryDetailAdd(didFinishAddTaskCategory taskCategory: TaskCategory)
    func taskCategoryDetailEdit(didFinishEditTaskCategory taskCategory: TaskCategory,shouldDeleteCategoty oldCategory: TaskCategory)
}

class TaskCategoryDetailViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var taskCategoryDetailDelegate: TaskCategoryDetailDelegate?
    var taskCategoryToEdit: TaskCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tc = taskCategoryToEdit {
            navigationItem.title = "编辑分类"
            textField.text = tc.name
        }
        //设置保存按钮初始化不可见
        saveButton.isEnabled = false
        //监听 saveButtonStatus 方法
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveButtonStatus(sender:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    //设置保存按钮在文本框中无文字时不可点击
    @objc func saveButtonStatus(sender: NSNotification){
        if(!self.textField.text!.isEmpty) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if let taskCategoryDetailDelegate = taskCategoryDetailDelegate {
            if var tc = taskCategoryToEdit {
                let oldTaskCategory = tc
                tc.name = textField.text!
                taskCategoryDetailDelegate.taskCategoryDetailEdit(didFinishEditTaskCategory: tc, shouldDeleteCategoty: oldTaskCategory)
            } else {
                if let name = textField.text {
                    taskCategoryDetailDelegate.taskCategoryDetailAdd(didFinishAddTaskCategory: TaskCategory(name: name))
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
