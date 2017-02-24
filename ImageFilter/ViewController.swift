//
//  ViewController.swift
//  ImageFilter
//
//  Created by Wilson Yuan on 2017/2/24.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var filterImageView: UIImageView!
    lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: .openGLES2)!
        let context = CIContext(eaglContext: eaglContext, options: [kCIContextWorkingColorSpace : NSNull()])
        return context;
    }()
    
    lazy var filter = CIFilter(name: "CIGaussianBlur")!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let ciImage = CIImage(image: UIImage(named: "group5")!) else { return }
        
        self.filter.setValue(ciImage, forKey: kCIInputImageKey)
        self.filter.setValue(NSNumber(value: 30), forKey: kCIInputRadiusKey)
        
        guard let filterImage = self.filter.outputImage else {
            return;
        }
        
        let image = UIImage(ciImage: filterImage)
        
        writeImageToDocument(image: image)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        print("rect: \(rect), extent: \(filterImage.extent)")
        
        guard let outPutImage = self.context.createCGImage(filterImage, from: rect) else {
            return;
        }
        
        let outImage = UIImage(cgImage: outPutImage)
        
        writeImageToDocument(image: outImage)
        
        self.filterImageView.image = outImage
    }
    
    func writeImageToDocument(image: UIImage?) -> Void {
        guard let image = image else {
            return
        }
        let data = UIImageJPEGRepresentation(image, 0.8)
        guard let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last else {
            return
        }
        let timeinterval = Date().timeIntervalSince1970
        let imagePath = path.appending("/image\(timeinterval).png")
        let url = URL(fileURLWithPath: imagePath)
        
        do {
            try data?.write(to: url)
        } catch {
            print("error: \(error)");
        }
        
        print("image path: \(imagePath)");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

