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
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var rawImage = UIImage()
    
    var ciImage = CIImage()
    
    
    lazy var context: CIContext = {
        
        let eaglContext = EAGLContext(api: .openGLES2)!
        let context = CIContext(eaglContext: eaglContext, options: [kCIContextWorkingColorSpace : NSNull()])
        return context;
    }()
    
    lazy var filter = CIFilter(name: "CIGaussianBlur")!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let rawImage = UIImage(named: "group5") else {
            return
        }
        
        guard let ciImage = CIImage(image: rawImage) else {
            return
        }
        
        self.filter.setValue(ciImage, forKey: kCIInputImageKey)
        self.filter.setValue(NSNumber(value: 30), forKey: kCIInputRadiusKey)
        
        guard let filterImage = self.filter.outputImage else {
            return;
        }
        self.rawImage = rawImage
        self.ciImage = filterImage;
        
        let image = UIImage(ciImage: filterImage)
        
        writeImageToDocument(image: image)
        
        let rect = filterImage.extent
        //CGRect(x: -200, y: -100, width: image.size.width, height: image.size.height)
        
        //plus: rawimage: (268.0, 406.0) extent: (-192.0, -192.0, 1200.0, 1616.0),
        //6: rawimage: (268.0, 406.0) extent: (-192.0, -192.0, 928.0, 1200.0)
        //5: rawimage: (268.0, 406.0) extent: (-192.0, -192.0, 928.0, 1200.0)

        print("rawimage: \(rawImage.size) \n rect: \(rect), \n extent: \(filterImage.extent)")
        
        guard let outPutImage = self.context.createCGImage(filterImage, from: rect) else {
            return;
        }
        
        widthConstraint.constant = blurViewWidth(for: rawImage, ciImage: filterImage)
        self.view.layoutIfNeeded()
        
        let outImage = UIImage(cgImage: outPutImage)
        
        writeImageToDocument(image: outImage)
        
        self.filterImageView.image = outImage
    }
    
    @IBAction func slideValue(_ sender: UISlider) {
        widthConstraint.constant = blurViewWidth(for: rawImage, ciImage: ciImage, scale: sender.value)
        self.view.layoutIfNeeded()
    }

    func blurViewWidth(`for` image: UIImage, ciImage: CIImage, scale: Float = 0.8) -> CGFloat {
        
        let imageWith = image.size.width
        let ciImageWidth = ciImage.extent.size.width
        let cixOffset = ciImage.extent.origin.x;
        //
        let xOffset = fabs(cixOffset) * imageWith / (ciImageWidth - 2 * fabs(cixOffset))
        //width
        let viewWidth = xOffset * CGFloat(scale) * 2 + imageWith;
        print("imageWith: \(imageWith), ciImageWidth: \(ciImageWidth),xOffset: \(xOffset), viewWidth:\(viewWidth)")
        return CGFloat(ceilf(Float(viewWidth)))
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
        
        print("image path: \(imagePath), image size: \(image.size)");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

