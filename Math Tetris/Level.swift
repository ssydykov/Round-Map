import Foundation

class Level: NSObject, NSCoding {
    
    // Fields
    var id: Int = 0
    var label: String = ""
    var status: Bool = true
    var stars: Int = 0
    var time: String = ""
    
    // Constructor
    init(_ id: Int, _ label: String, _ status: Bool, _ stars: Int, _ time: String) {
        
        self.id = id
        self.label = label
        self.status = status
        self.stars = stars
        self.time = time
    }
    
    // Empty constructor
    override init() {
        
    }
    
    // Decoder
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        self.id = decoder.decodeInteger(forKey: "id")
        self.label = decoder.decodeObject(forKey: "label") as! String
        self.status = decoder.decodeBool(forKey: "status")
        self.stars = decoder.decodeInteger(forKey: "stars")
        self.time = decoder.decodeObject(forKey: "time") as! String
    }
    
    // Encoder
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.label, forKey: "label")
        coder.encode(self.status, forKey: "status")
        coder.encode(self.stars, forKey: "stars")
        coder.encode(self.time, forKey: "time")
    }
}
