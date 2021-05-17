//
//  ContentView.swift
//  Calculator_SwiftUI
//
//  Created by Zhengyi on 2021/4/27.
//

import SwiftUI

enum CalculatorButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case decimal = "."
    case add = "+"
    case subtract = "–"
    case divide = "÷"
    case mutliply = "×"
    case equal = "="
    case clear = "AC"
    case percent = "%"
    case negativity = "-/+"
    
    var color: Color {
        switch self {
        case .add, .equal, .mutliply, .divide, .subtract:
            return Color(.systemTeal)
        case .clear, .percent, .negativity:
            return Color(.lightGray)
        default:
            return .orange
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

extension Double {
    var cleanZero : String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%g", self) : String(self)
    }
}

struct ContentView: View {
    
    @State var result:String = "0"
    @State var currentResult:Double = 0
    @State var currentOperation: Operation = .none
    @State var lastEvaluate: Bool = false
    @State var lastOperate: Bool = false
    
    let spacing: CGFloat = 12
    let buttons: [[CalculatorButton]] = [
        [.clear, .negativity, .percent, .divide],
        [.seven, .eight, .nine, .mutliply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    func calculate() -> Double? {
        if (result == "") {
            return nil
        }
        let oprand = Double(result)
        if (oprand == nil) {
            return nil
        }
        
        switch currentOperation {
        case .divide:
            return currentResult / (oprand ?? 1)
        case .multiply:
            return currentResult * (oprand ?? 1)
        case .add:
            return currentResult + (oprand ?? 0)
        case .subtract:
            return currentResult - (oprand ?? 0)
        default:
            return Double(result)
        }
    }
    
    func evaluate() {
        let res:Double? = calculate()
        if (res == nil || res == Double.infinity) {
            result = "Error"
        } else {
            result = (res ?? 0.0).cleanZero
            currentResult = res ?? 0
        }
        lastEvaluate = true
    }
    
    func didTap(button: CalculatorButton) {
        switch button {
        case .clear:
            result = "0"
            lastOperate = false
            lastEvaluate = false
            currentOperation = .none
            currentResult = 0
        case .negativity:
            if String(result).starts(with: "-") {
                let s:String = result
                let offset = s.index(s.startIndex, offsetBy: 1)
                result = String(s[offset...])
            } else if result == "0" {
                // Do nothing
            }else {
                result = "-" + result
            }
        case .percent:
            var temp = Double(result)
            temp = (temp ?? 0) / 100
            result = String(temp ?? 0)
            lastEvaluate = true
        case .divide, .mutliply, .add, .subtract:
            if (currentOperation != .none) {
                evaluate()
            }
            switch button {
            case .divide:
                currentOperation = .divide
            case .mutliply:
                currentOperation = .multiply
            case .add:
                currentOperation = .add
            case .subtract:
                currentOperation = .subtract
            default:
                currentOperation = .none
            }
            currentResult = Double(result) ?? 0
            lastOperate = true
        case .equal:
            evaluate()
            lastOperate = true
            currentOperation = .none
        default:
            if lastOperate || lastEvaluate || result == "0" {
                result = ""
            }
            result = result + button.rawValue
            lastEvaluate = false
            lastOperate = false
        }
        
    }
    
    func buttonWidth(_ button: CalculatorButton) -> CGFloat {
        if (button == .zero) {
            return (UIScreen.main.bounds.width - (5*spacing)) / 2 + spacing
        }
        return (UIScreen.main.bounds.width - (5*spacing)) / 4
    }
    
    func buttonHeight(_ button: CalculatorButton) -> CGFloat {
        return (UIScreen.main.bounds.height - (5*spacing)) / 5 / 2.0
    }
    
    @State var orientation = UIDevice.current.orientation

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    
    var bodyGroup: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(result)
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size: 70))
                } .padding()
                
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) {button in
                            Button(action: {
                                didTap(button: button)
                            }, label: {
                                Text(button.rawValue)
                                    .font(.system(size: 32))
                                    .frame(
                                        width: buttonWidth(button),
                                        height: buttonHeight(button)
                                    )
                                    .background(button.color)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        )
                        }.padding(.bottom, 3)
                    }
                }
                
            }
        }
    }
    
    var body: some View {
        Group {
            if orientation.isLandscape {
                bodyGroup
            } else {
                bodyGroup
            }
        }.onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
