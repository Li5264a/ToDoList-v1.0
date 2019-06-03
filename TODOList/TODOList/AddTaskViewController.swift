//
//  AddTaskViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/31.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

protocol AddTaskDelegate: class {
    func addTaskViewController(controller: AddTaskViewController , didFinishAddTask task: Task)
}

class AddTaskViewController: UITableViewController,UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    //weak解决内存泄漏问题
    weak var addTaskDelegate: AddTaskDelegate?
    
    var taskToEdit: Task?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置保存按钮初始化不可见
        saveButton.isEnabled = false
        
        if let taskToEdit = taskToEdit {
            self.textField.text = taskToEdit.name
            self.navigationItem.title = "编辑任务"
        }
    }
    
    //使输入框首先响应 实现点击添加按钮之后跳转到添加任务界面自动选中输入框
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        textField.becomeFirstResponder()
    }
    
    //保存按钮
    @IBAction func save(_ sender: Any) {
        if let addTaskDelegate = addTaskDelegate {
            let task = Task()
            task.name = textField.text!
            addTaskDelegate.addTaskViewController(controller: self, didFinishAddTask: task)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //取消按钮 返回上一页
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //设置tableView的行 选中效果消失（背景色消失）
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    //设置保存按钮在文本框中无文字时不可点击  使用代理模式完成
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = NSString (string: textField.text!)
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length > 0 {
            saveButton.isEnabled = true
        }else {
            saveButton.isEnabled = false
        }
        return true
    }
}
