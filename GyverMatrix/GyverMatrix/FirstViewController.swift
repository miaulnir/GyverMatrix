//
//  FirstViewController.swift
//  GyverMatrix
//
//  Created by Андрей Рыбалкин on 03.12.2022.
//

import UIKit
import Network

class FirstViewController: UIViewController {
    
    var _host: NWEndpoint.Host = "192.168.4.1"
    var _port: NWEndpoint.Port = 2390

    var connection: NWConnection?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipTextField.delegate = self
        portTextField.delegate = self
        requestTextField.delegate = self
        
        view.backgroundColor = .lightGray
        // Do any additional setup after loading the view.
        
        view.addSubview(stackView)
        view.addSubview(responseLabel)
    }
    
    private lazy var ipTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "IP adress"
        tf.text = "192.168.4.1"
        tf.borderStyle = .line
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.black.cgColor
        return tf
    }()

    private lazy var portTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Port"
        tf.text = "2390"
        tf.borderStyle = .line
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.black.cgColor
        return tf
    }()
    
    private lazy var requestTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Request"
        tf.borderStyle = .line
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.black.cgColor
        return tf
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Connect", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(setConnect), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(sendToEsp), for: .touchUpInside)
        return button
    }()
    
    private lazy var showInfoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Show info", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        return button
    }()

    private lazy var responseLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: stackView.frame.maxY, width: self.view.frame.width, height: 100))
        label.textAlignment = .center
        label.text = "response"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 50, height: 300))
        stack.center = self.view.center
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.addArrangedSubview(ipTextField)
        stack.addArrangedSubview(portTextField)
        stack.addArrangedSubview(requestTextField)
        
        stack.addArrangedSubview(connectButton)
        stack.addArrangedSubview(sendButton)
        stack.addArrangedSubview(showInfoButton)

       return stack
    }()
    
    @objc func setConnect() {
        guard
            let host = self.ipTextField.text,
            let port = self.portTextField.text
        else { return }
        
        self.connect(host: host, port: port)
    }
    
    @objc func sendToEsp() {
        sendUDP(self.requestTextField.text ?? "")
    }
    
    @objc func showInfo() {
        let infoVC = InfoViewController()
        present(infoVC, animated: true)
    }
    
    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                NSLog("Data has been sent")
                self.connection!.receiveMessage { (data, context, isComplete, error) in
                    guard let myData = data else { return }
                    NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
                }
            }
        }))
    }
    
    
    func sendUDP(_ content: String) {
        
        guard !content.isEmpty else { return }
        
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    func connect(host: String, port: String) {

        guard let port = NWEndpoint.Port(port) else { return }
        let host = NWEndpoint.Host(host)

        self.connection = NWConnection(host: host, port: port, using: .udp)
        
        guard let connection else { return }

        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Entered state: preparing")
            case .ready:
                NSLog("Entered state: ready")
            case .setup:
                NSLog("Entered state: setup")
            case .cancelled:
                NSLog("Entered state: cancelled")
            case .waiting:
                NSLog("Entered state: waiting")
            case .failed:
                NSLog("Entered state: failed")
            default:
                NSLog("Entered an unknown state")
            }
        }
        
        connection.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Connection is viable")
                DispatchQueue.main.async {
                    self.connectButton.backgroundColor = .green
                }
                
            } else {
                NSLog("Connection is not viable")
                DispatchQueue.main.async {
                    self.connectButton.backgroundColor = .red
                }
            }
        }
        
        connection.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("A better path is availble")
            } else {
                NSLog("No better path is available")
            }
        }
        
        connection.start(queue: .global())
    }



}

extension FirstViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

