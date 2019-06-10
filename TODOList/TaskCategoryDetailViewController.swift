//
//  TaskCategoryDetailViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/6/9.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

protocol TaskCategoryDetailDelegate: class {
    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController , didFinishAddTaskCategory taskCategory: TaskCategory)
    func taskCategoryDetailViewController(sender: TaskCategoryDetailViewController , didFinishEditTaskCategory taskCategory: TaskCategory )
}

class TaskCategoryDetailViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    weak var taskCategoryDetailDelegate: TaskCategoryDetailDelegate?
    var taskCategoryToEdit: TaskCategory?
    
    override func viewDidLoad() {
        if let tc = taskCategoryToEdit {
            navigationItem.title = "编辑分类"
            textField.text = tc.name
        }
        super.viewDidLoad()
    }
    
    @IBAction func save(_ sender: Any) {
        if var tc = taskCategoryToEdit {
            tc.name = textField.text!
            taskCategoryDetailDelegate?.taskCategoryDetailViewController(sender: self, didFinishEditTaskCategory: tc)
        } else {
            if let name = textField.text {
                taskCategoryDetailDelegate?.taskCategoryDetailViewController(sender: self, didFinishAddTaskCategory: TaskCategory(name: name))
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
