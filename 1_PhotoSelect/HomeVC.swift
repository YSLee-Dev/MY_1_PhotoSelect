//
//  HomeVC.swift
//  1_PhotoSelect
//
//  Created by 이윤수 on 2022/06/22.
//

import UIKit
import SnapKit
import PhotosUI

class HomeVC : UICollectionViewController {
    
    lazy var picker : PHPickerViewController = {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 최대 사진 선택 개수 (0은 무제한)
        config.filter = .images // 이미지만 선택 가능
        
        let picker = PHPickerViewController(configuration: config) // config를 미리 넣어놔야 함
        picker.delegate = self
        return picker
    }()
    
    var photoList : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSet()
    }
    
    private func viewSet(){
        self.title = "사진 선택기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickAddPhoto(_:))), animated: true)
    }
    
    @objc private func clickAddPhoto(_ sender:Any){
        self.present(self.picker, animated: true)
    }
}

extension HomeVC : PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        self.dismiss(animated: true)
        
        if results.isEmpty{
            let alert = UIAlertController(title: "사진이 선택되지 않았습니다.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: true)
        }else{
            if !self.photoList.isEmpty{
                self.photoList = []
            }
            results.forEach{ [weak self] in
                let pro = $0.itemProvider
                if pro.canLoadObject(ofClass: UIImage.self){
                    pro.loadObject(ofClass: UIImage.self){ [weak self] image, error in
                        guard let self = self else {return}
                        guard let UiImage = image as? UIImage else {return}
                        self.photoList.append(UiImage)
                        print(self.photoList)
                    }
                }
            }
        }
    }
}
