/**
 * Creates a new type that is used to represent error information in Swift.
 *
 * This is a new Swift-specific error type used to return error information. The primary usage of this object is to
 * return it as a `Failable` or `FailableOf<T>` from function that could fail.
 *
 * Example:
 *    `func readContentsOfFileAtPath(path: String) -> Failable<String>`
 */
import Foundation

public struct Error {
    public typealias ErrorInfoDictionary = Dictionary<String, Any>
    
    /// The error code used to differentiate between various error states.
    public let code: Int
    
    /// A string that is used to group errors into related error buckets.
    public let domain: String
    
    /// A place to store any custom information that needs to be passed along with the error instance.
    public let userInfo: ErrorInfoDictionary
    
    /// Initializes a new `Error` instance.
    public init(code: Int, domain: String, userInfo: ErrorInfoDictionary?) {
        self.code = code
        self.domain = domain
        if let info = userInfo {
            self.userInfo = info
        }
        else {
            self.userInfo = [String:Any]()
        }
    }
    
    public var localizedDescription: String {
        if let desc = userInfo[NSLocalizedDescriptionKey] as String? {
            return desc
        }
        return "error unknown !"
    }

}