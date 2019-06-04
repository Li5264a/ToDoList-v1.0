//
//  TaskDetailViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/31.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

protocol TaskDetailDelegate: class {
    func taskDetailViewController(controller: TaskDetailViewController , didFinishAddTask task: Task)
    func taskDetailViewController(controller: TaskDetailViewController , didFinishEditTask task: Task)
}

class TaskDetailViewController: UITableViewController,UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    //weak解决内存泄漏问题
    weak var taskDetailDelegate: TaskDetailDelegate?
    
    var taskToEdit: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置保存按钮初始化不可见
        saveButton.isEnabled = false
        
        //监听 saveButtonStatus 方法
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveButtonStatus(sender:)), name: UITextField.textDidChangeNotification, object: nil)
        
        if let taskToEdit = taskToEdit {
            self.textField.text = taskToEdit.name
            self.navigationItem.title = "编辑任务"
        }
    }
    
    //设置保存按钮在文本框中无文字时不可点击
    @objc func saveButtonStatus(sender: NSNotification){
        if(!self.textField.text!.isEmpty) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    //使输入框首先响应 实现点击添加按钮之后跳转到添加任务界面自动选中输入框
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    //保存按钮
    @IBAction func save(_ sender: Any) {
        if let taskDetailDelegate = taskDetailDelegate {
            if var taskToEdit = taskToEdit {
                taskToEdit.name = textField.text!
                taskDetailDelegate.taskDetailViewController(controller: self, didFinishEditTask: taskToEdit)
            } else {
                if let name = textField.text {
                    taskDetailDelegate.taskDetailViewController(controller: self, didFinishAddTask: Task(name: name, isCheck: false))
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //取消按钮 返回上一页
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
