//
//  TaskDetailViewController.swift
//  TODOList
//
//  Created by Kang Li on 2019/5/31.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications
protocol TaskDetailDelegate: class {
    func taskDetailViewController(controller: TaskDetailViewController , didFinishAddTask task: Task)
    func taskDetailViewController(controller: TaskDetailViewController , didFinishEditTask task: Task)
}

class TaskDetailViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var remindTimeField: UITextField!
    
    @IBOutlet weak var timeSwitch: UISwitch!
    
    //weak解决内存泄漏问题
    weak var taskDetailDelegate: TaskDetailDelegate?
    
    var taskToEdit: Task?
    
    var taskCategory: TaskCategory?
    
    var components = DateComponents()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载textView配置方法
        textViewConfig()
        
        //设置保存按钮初始化不可见
        saveButton.isEnabled = false
        
      //  insertString("欢迎欢迎!")
      //  insertImage(UIImage(named: "icon")!, mode:.fitTextLine)
        
        //监听 saveButtonStatus 方法
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveButtonStatus(sender:)), name: UITextView.textDidChangeNotification, object: nil)
        
        //若选中编辑任务，将选中的内容显示到输入框中
        if let taskToEdit = taskToEdit {
            self.textView.text = taskToEdit.name
            self.remindTimeField.text = taskToEdit.remindTime
            self.navigationItem.title = "编辑任务"
        }
        //调用设置提醒时间功能
        remindTime()
       // remindTask()
    }
    
    //设置保存按钮在文本框中无文字时不可点击
    @objc func saveButtonStatus(sender: NSNotification){
        if(!self.textView.text!.isEmpty) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    //使输入框首先响应 实现点击添加按钮之后跳转到添加任务界面自动选中输入框
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     //   textField.becomeFirstResponder()
        textView.becomeFirstResponder()
    }
    
    func textViewConfig() {
        //设置内容是否可选
        textView.isSelectable = true
        //设置字体
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        //设置字体颜色
        textView.textColor = UIColor.gray
        //设置对其方式
        textView.textAlignment = NSTextAlignment.center
        //给文本中所有的电话和网址自动添加链接
        textView.dataDetectorTypes = UIDataDetectorTypes.all
    }
    
    //保存按钮
    @IBAction func save(_ sender: Any) {
        if let taskDetailDelegate = taskDetailDelegate {
            if var taskToEdit = taskToEdit {
                taskToEdit.name = textView.text!
                taskToEdit.remindTime = remindTimeField.text!
                taskDetailDelegate.taskDetailViewController(controller: self, didFinishEditTask: taskToEdit)
            } else {
                if let name = textView.text, let time = remindTimeField.text {
                    taskDetailDelegate.taskDetailViewController(controller: self, didFinishAddTask: Task(name: name, isCheck: false, taskCategory: taskCategory!.name, remindTime: time))
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //取消按钮 返回上一页
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //插入的图片附件的尺寸样式
    enum ImageAttachmentMode {
        case `default`  //默认（不改变大小）
        case fitTextLine  //使尺寸适应行高
        case fitTextView  //使尺寸适应textView
    }
    
    //插入文字
    func insertString(_ text:String) {
        //获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        //获得目前光标的位置
        let selectedRange = textView.selectedRange
        //插入文字
        let attStr = NSAttributedString(string: text)
        mutableStr.insert(attStr, at: selectedRange.location)
        
        //设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 22),
                                range: NSMakeRange(0,mutableStr.length))
        //再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location + attStr.length, 0)
        
        //重新给文本赋值
        textView.attributedText = mutableStr
        //恢复光标的位置（上面一句代码执行之后，光标会移到最后面）
        textView.selectedRange = newSelectedRange
    }
    
    func insertImage(_ image: UIImage, mode: ImageAttachmentMode = .default) {
        //获取textview的所有文本，转化为可变文本
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        //创建附件
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
    
        //设置附件的照片
        imgAttachment.image = image
        
        if mode == .fitTextLine {
            imgAttachment.bounds = CGRect(x: 0, y: -4, width: textView.font!.lineHeight, height: textView.font!.lineHeight)
        } else if mode == .fitTextView {
            let imageWidth = textView.frame.width - 10
            let imageHeight = image.size.height/image.size.width*imageWidth
            imgAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }
        
        //创建NSAttributedString属性化文本
        var imgAttachmentString: NSAttributedString
        //将附件转化问此文本
        imgAttachmentString = NSAttributedString(attachment: imgAttachment)
        
        //获得目前光标的位置
        let selectedRange = textView.selectedRange
        //插入图片
        mutableStr.insert(imgAttachmentString, at: selectedRange.location)
        //设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 22),
                                range: NSMakeRange(0,mutableStr.length))
        //再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
        
        //重新给文本赋值
        textView.attributedText = mutableStr
        //恢复光标的位置（上面一句代码执行之后，光标会移到最后面）
        textView.selectedRange = newSelectedRange
        //移动滚动条（确保光标在可视区域内）
        self.textView.scrollRangeToVisible(newSelectedRange)
        
    }
    
    //设置提醒时间
    func remindTime() {
        timeSwitch.addTarget(self, action: #selector(switchDidChange), for:.valueChanged)
        //创建日期选择器
        let datePicker = UIDatePicker(frame: CGRect(x:0, y:0, width:320, height:216))
        //将日期选择器区域设置为中文，则选择器日期显示为中文
        datePicker.locale = Locale(identifier: "zh_CN")
        remindTimeField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(dateChanged),
                             for: .valueChanged)
    }
    
    //日期选择器响应方法
    @objc func dateChanged(datePicker : UIDatePicker){
        //更新提醒时间文本框
        let formatter = DateFormatter()
        //日期样式
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        remindTimeField.text = formatter.string(from: datePicker.date)
        
        //获取当前的Calendar(用于作为转换Date和DateComponents的桥梁)
    //    let calendar = Calendar.current
        //使用（时区+时间）重载函数进行转换（这里参数in使用TimeZone的构造器创建了一个东八区的时区）
     //   components = calendar.dateComponents(in: TimeZone.init(secondsFromGMT: 3600*8)!, from: datePicker.date)
    }
    
    //UISwitch监听方法
    @objc func switchDidChange() {
        if timeSwitch.isOn {
            remindTimeField.isEnabled = true
        } else {
            remindTimeField.isEnabled = false
        }
        
    }
    
    func remindTask() {
        //设置推送内容
        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = taskToEdit!.name
        
        components.year = 2019
        components.month = 06
        components.day = 12
        components.hour = 13
        components.minute = 26
        
        //设置通知触发器
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        
        //设置请求标识符
        let requestIdentifier = "com.hangge.testNotification"
        
        //设置一个通知请求
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        //将通知请求添加到发送中心
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Time Interval Notification scheduled: \(requestIdentifier)")
            }
        }
    }
}
