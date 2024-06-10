import UIKit

open class TextField: UITextField {
    
    public typealias Config = (TextField) -> Swift.Void
    
//    public func configure(configurate: Config?) {
//        configurate?(self)
//    }
    
    public typealias Action = (UITextField) -> Void
    
    fileprivate var actionEditingChanged: Action?
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: (leftTextPadding ?? 8) + (leftView?.width ?? 0) + (leftViewPadding ?? 0), dy: 0)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: (leftTextPadding ?? 8) + (leftView?.width ?? 0) + (leftViewPadding ?? 0), dy: 0)
    }
    
    
    public var leftViewPadding: CGFloat?
    public var leftTextPadding: CGFloat?
    
    
    public func action(closure: @escaping Action) {
        if actionEditingChanged == nil {
            addTarget(self, action: #selector(TextField.textFieldDidChange), for: .editingChanged)
        }
        actionEditingChanged = closure
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        actionEditingChanged?(self)
    }
}
