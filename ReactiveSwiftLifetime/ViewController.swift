import ReactiveCocoa
import ReactiveSwift
import UIKit

class ViewController: UIViewController {
    
    let id: UUID = .init()
    var counter: Int = 0
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Present Child", for: .normal)
        button.addTarget(self, action: #selector(presentChild), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 200, height: 200)
        button.backgroundColor = .red
        return button
    }()
    
    @objc private func presentChild() {
        present(ViewController(), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(button)
        button.center = view.center
        
        timerSignalProducer(interval: 1)
            .take(duringLifetimeOf: self) // TYPE 1
            .flatMap(.concat) { [weak self] counter in
                self?.delayedSignalProducer(for: counter) ?? .empty
            }
//            .take(duringLifetimeOf: self) // TYPE 2
            .startWithValues { [weak self, id] _ in
                debugPrint(id, self?.state)
            }
    }
    
    var state: String {
        "\(id.uuidString): \(counter)"
    }
}

extension ViewController {
    
    func delayedSignalProducer(for counter: Int) -> SignalProducer<Int, Never> {
        SignalProducer { [id] observer, lifetime in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                debugPrint(id, "delayedSignalProducer: \(counter)")
                observer.send(value: counter)
                observer.send(.completed)
            }
            
            lifetime.observeEnded {
                timer.invalidate()
            }
        }
    }
    
    func timerSignalProducer(interval: TimeInterval) -> SignalProducer<Int, Never> {
        return SignalProducer { [id] observer, lifetime in
            
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self, id] _ in
                guard let self else {
                    return
                }
                
                debugPrint(self.id, "timerSignalProducer: \(self.counter)")
                observer.send(value: self.counter)
                self.counter += 1
            }
            
            lifetime.observeEnded {
                timer.invalidate()
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeElapsed)) {
//                guard !lifetime.hasEnded else {
//                    observer.sendInterrupted()
//                    return
//                }
                    
//                    if i == 9 {
//                        observer.sendCompleted()
//                    }
//            }
            
        }
    }
    
}
