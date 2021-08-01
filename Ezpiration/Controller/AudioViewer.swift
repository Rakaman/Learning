//
//  AudioViewer.swift
//  Ezpiration
//
//  Created by Raka Mantika on 01/08/21.
//

import UIKit
import AVFoundation

class AudioViewer: UIViewController, AVAudioPlayerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    var newRecordName = ""
    var newRecordDate = Date()
    
    @IBOutlet weak var recordTtl: UILabel!
    @IBOutlet weak var lyricButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var lyricTitle: UIButton!
    @IBOutlet weak var lyricTtl: UITextField!
    @IBOutlet weak var titleLyric: UITextView!
    
    var soundPlayer : AVAudioPlayer!
    var recordTitle = ""
    var rowNumber = 0
    
    var alert : UIAlertController?
    var isFavourited = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecords()
        
        print("sapi spai \(rowNumber)")
        playButton.layer.cornerRadius = 35
        
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTitle(_:)))
        self.navigationItem.rightBarButtonItem = edit
        
        lyricButton.layer.cornerRadius = 10
        recordTtl.text = recordTitle
        // Do any additional setup after loading the view.
        
        titleLyric?.text = records![rowNumber].file_name
        
        lyricTtl.placeholder = "Title"
        lyricTtl.keyboardType = UIKeyboardType.emailAddress // Just to select one
        lyricTtl.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        
        lyricTtl?.text = records![rowNumber].file_name
        
    }
    
//    Ini metode edit title di tempat
//    @IBAction func edit(_ sender: UIBarButtonItem) {

//        if (UIBarButtonItem.titleTextAttributes(UIBarItem) == "Edit"){
//            recordTtl.isHidden = true
//            titleLyric.isHidden = false
//        }
        
//    }
//
//    @IBAction func saveTitle(_ sender: Any) {
//        records![rowNumber].file_name = titleLyric?.text
////        records![rowNumber].file_name = lyricTtl?.text
//        do{
//            try self.context.save()
//        }catch{
//            print(error.localizedDescription)
//        }
//        self.fetchRecords()
//    }
    
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
    
    func fetchRecords(){
        do {
            self.records = try context.fetch(Records.fetchRequest())
            DispatchQueue.main.async {
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func editTitle(_ sender: Any) {
        let record = self.records![rowNumber]
        self.alert = UIAlertController(title: "Edit Title", message: "Do you want to edit your title?", preferredStyle: .alert)
        self.alert?.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Title"
            textField.keyboardType = UIKeyboardType.emailAddress // Just to select one
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })

        let textField = self.alert?.textFields![0]
        textField?.text = record.file_name

        let yesAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = self.alert?.textFields![0]
            record.file_name = textField?.text
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.fetchRecords()
            self.recordTtl.text = textField?.text
            
            var url = self.getDocumentDirectory().appendingPathComponent(self.recordTitle)
            var rv = URLResourceValues()
            rv.name = textField?.text
            do{
                try url.setResourceValues(rv)
            }catch{
                print(error.localizedDescription)
            }
            
            self.setupPlayer()
            
        })

        self.alert?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        yesAction.isEnabled = false
        self.alert?.addAction(yesAction)

        self.present(self.alert!, animated: true, completion: nil)
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func setupPlayer(){
        let record = self.records![rowNumber]
        let audioFilename = getDocumentDirectory().appendingPathComponent(record.file_name!)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    @IBAction func playAudio(_ sender: Any) {
        if playButton.titleLabel?.text == "Play"{
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            print("aku adalah lokasi file : \(path)")
            playButton.setTitle("Stop", for: .normal)
            setupPlayer()
            soundPlayer.play()
        }else{
            soundPlayer.stop()
            playButton.setTitle("Play", for: .normal)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ recorder : AVAudioPlayer, successfully flag : Bool) {
        playButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func lyricPopUp(_ sender: Any) {
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if segue.destination is LyricScreen {
//            let vc = segue.destination as? LyricScreen
//            vc?.lyricTitle = recordTitle
//            vc?.rowNo = rowNumber
//        }
//    }

    
}
