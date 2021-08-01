//
//  ViewController.swift
//  Ezpiration
//
//  Created by Raka Mantika on 01/08/21.
//

import UIKit
import CoreData
import Speech
import AVFoundation

class RecordingController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {
    
    var soundRecorder : AVAudioRecorder!
    var fileName : String = "temp"
    var audio : [URL] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-EN"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    var newRecordName = ""
    var newRecordDate = Date()
    var newRecordStt = ""

    @IBOutlet weak var bannerHome: UIImageView!
    @IBOutlet weak var bannerText1: UILabel!
    @IBOutlet weak var bannerText2: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var borderBtn: UILabel!
//    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableInspirations: UITableView!
    
    var alert : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        //set image for button
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        
        //add function for button
//        button.addTarget(self, action: Selector(("fbButtonPressed")), for: UIControl.Event.touchUpInside)
        //set frame
//        button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)

        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let myFilesPath = "\(path)"
        let files = FileManager.default.enumerator(atPath: myFilesPath)
        while let file = files?.nextObject() {
            print("\(file) ini sapi")
        }
        
        navigationController?.navigationBar.barTintColor = UIColor.systemOrange
        
        setupRecorder()
        fetchRecords()
        
        recordBtn.layer.cornerRadius = 40
        borderBtn.layer.cornerRadius = 60
        borderBtn.layer.borderColor = UIColor.systemGray.cgColor
        borderBtn.layer.borderWidth = 0.5
        
//        navigationBar.standardAppearance.configureWithTransparentBackground()
        
        self.tableInspirations.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableInspirations.rowHeight = 92
        self.tableInspirations.delegate = self
        self.tableInspirations.dataSource = self
        self.tableInspirations.separatorStyle = .none
        
        if(records?.isEmpty == true){
            bannerHome.isHidden = false
            bannerText1.isHidden = false
            bannerText2.isHidden = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableInspirations.reloadData()
    }
    
    @IBAction func sortItem(_ sender: Any){
        
    }
    
    func bannerDisappear(){
        bannerHome.isHidden = true
        bannerText1.isHidden = true
        bannerText2.isHidden = true
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func setupRecorder(){
        let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        let recordingSetting = [AVFormatIDKey : kAudioFormatAppleLossless, AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue, AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey : 2, AVSampleRateKey : 44100.2] as [String : Any]
        do {
            soundRecorder = try AVAudioRecorder(url: audioFileName, settings: recordingSetting)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    private func startRecording() throws {
        newRecordStt = "The record is empty :)"
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
                self.newRecordStt = result.bestTranscription.formattedString
                
//                save ke core data nya disini check is final
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // setup mic untuk record
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
    }
    
    func fetchRecords(){
        do {
            self.records = try context.fetch(Records.fetchRequest())
            DispatchQueue.main.async {
                self.tableInspirations.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func alertRecordingName(_ sender: Any) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }else {
            do {
                try startRecording()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if (recordBtn.title(for: .normal) == "Record"){
            
            bannerDisappear()
            soundRecorder.record()
            
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "ddMMyy-HHmmss"
            let formattedDate = format.string(from: date)
            newRecordName = "Inspiration \(formattedDate)"
            newRecordDate = date
            
            recordBtn.layer.cornerRadius = 10
            recordBtn.setTitle("Stop", for: .normal)
        } else {
            soundRecorder.stop()
            
            recordBtn.layer.cornerRadius = 40
            self.recordBtn.setTitle("Record", for: .normal)
            
            //ini yang dimasukin ke core data
            let newRecords = Records(context: self.context)
            newRecords.file_name = newRecordName
            newRecords.date = newRecordDate
            newRecords.stt_result = newRecordStt
            do{
                try self.context.save()
            }catch{
                print("sapi \(error.localizedDescription)")
            }
            self.fetchRecords()

            var url = getDocumentDirectory().appendingPathComponent(fileName)
            var rv = URLResourceValues()
            rv.name = newRecordName
            do{
                try url.setResourceValues(rv)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder : AVAudioRecorder, successfully flag : Bool) {
        return
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
        } else {
            recordBtn.isEnabled = false
        }
    }
}

extension RecordingController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell{
            let files = self.records?[indexPath.row]
            // ambil data dari tabel records
            cell.labelTest.text = files?.file_name
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "dd-MM-yyyy"
            let formattedDate = format.string(from: date)
            cell.dateRecord.text = formattedDate
//            cell.dateRecord.text = ("\(String(describing: files?.date))")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            
            print("\(self.records![indexPath.row]) bebek ini")

            let recordToRemove = self.records![indexPath.row]
            print("\(recordToRemove.file_name!) ini sapi")
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
            let destinationPath = documentsPath.appendingPathComponent("\(recordToRemove.file_name!)")

            try! FileManager.default.removeItem(atPath: destinationPath)
            
            self.context.delete(recordToRemove)
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }

//            todo : delete file yang kesimpan disini
            self.fetchRecords()
            
            if(self.records?.isEmpty == true){
                self.bannerHome.isHidden = false
                self.bannerText1.isHidden = false
                self.bannerText2.isHidden = false
            }
        }
        delete.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //buat segue untuk open view controller sebelah
        let files = self.records![indexPath.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioViewer") as! AudioViewer
        self.navigationController?.pushViewController(vc, animated: true)
        vc.recordTitle = "\(files.file_name!)"
        vc.rowNumber = indexPath.row
    }
    
}

