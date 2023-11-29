import ReactiveSwift
import UIKit

class ViewController: UIViewController {
    
    let interval: Int
    
    init(interval: Int) {
        self.interval = interval
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        interval = 1
        super.init(coder: coder)
    }
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Present Child", for: .normal)
        button.addTarget(self, action: #selector(presentChild), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 200, height: 200)
        button.backgroundColor = .red
        return button
    }()
    
    @objc private func presentChild() {
        present(ViewController(interval: interval + 1), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(button)
        button.center = view.center
        
        let interval = self.interval
        
        timerSignalProducer(interval: interval)
            .startWithValues { value in
                print("timeElapsed = \(value) : interval = \(interval)")
            }
    }
}

extension ViewController {
    
    func timerSignalProducer(interval: Int) -> SignalProducer<Int, Never> {
        return SignalProducer { observer, lifetime in
            for i in 0 ..< 10 {
                let timeElapsed = interval * i
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeElapsed)) {
                    guard !lifetime.hasEnded else {
                        observer.sendInterrupted()
                        return
                    }
                    observer.send(value: timeElapsed)
                    if i == 9 {
                        observer.sendCompleted()
                    }
                }
            }
        }
    }
    
}
