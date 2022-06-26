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
    var bestList : [UIImage] = []
    var add = UIBarButtonItem()
    var reload = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSet()
    }
    
    private func viewSet(){
        self.title = "사진 선택기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickAddPhoto(_:)))
        self.reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clickReloadPhoto(_:)))
        
        self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.navigationItem.setRightBarButton(self.add, animated: true)
        self.collectionView.collectionViewLayout = createLayout()
    }
    
    @objc private func clickAddPhoto(_ sender:Any){
        self.present(self.picker, animated: true)
    }
    
    @objc private func clickReloadPhoto(_ sender:Any){
        self.collectionView.reloadData()
        print(photoList)
    
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionNumber, Environment -> NSCollectionLayoutSection? in
            let group = NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            guard let self = self else {return NSCollectionLayoutSection(group: group)}
            
            if self.bestList.isEmpty{
                return self.normalPhotoLayout()
            }else{
                if sectionNumber == 0{
                    return self.largePhotoLayout()
                }else{
                    return self.normalPhotoLayout()
                }
            }
        }
    }
    
    private func largePhotoLayout() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.47), heightDimension: .fractionalWidth(0.47))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.47))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private func normalPhotoLayout() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.23), heightDimension: .fractionalWidth(0.23))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.23))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        
        return NSCollectionLayoutSection(group: group)
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
                    }
                }
            }
            self.navigationItem.setRightBarButton(self.reload, animated: true)
        }
    }
}

// 컬렉션 뷰
extension HomeVC{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.bestList.isEmpty {
            return 1
        }else{
            return 2
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.bestList.isEmpty{
            return self.photoList.count
        }else{
            switch section{
            case 0:
                return self.bestList.count
            default:
                return self.photoList.count
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()}
        if !self.bestList.isEmpty && indexPath.section == 0{
            cell.photo.image = self.bestList[indexPath.row]
            return cell
        }else if self.bestList.isEmpty || indexPath.section != 0{
            cell.photo.image = self.photoList[indexPath.row]
            return cell
        }else{
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 대표사진 선택 불가하게
        if !(!self.bestList.isEmpty && indexPath.section == 0){
            // 대표사진 선택
            let alert = UIAlertController(title: "클릭한 사진을 대표사진으로 설정하시겠습니까? (최대 2개)", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel){ [weak self] _ in
                guard let self = self else {return}
                // 2개 이상일 시 맨 앞 항목은 다시 기본 셀로 복구
                if self.bestList.count != 2{
                    self.bestList.append(self.photoList[indexPath.row])
                    self.photoList.remove(at: indexPath.row)
                }else{
                    self.photoList.append(self.bestList.first ?? UIImage())
                    self.bestList.removeFirst()
                    self.bestList.append(self.photoList[indexPath.row])
                    self.photoList.remove(at: indexPath.row)
                }
                self.collectionView.reloadData()
            })
            alert.addAction(UIAlertAction(title: "취소", style: .default))
            self.present(alert, animated: true)
        }
    }
}
