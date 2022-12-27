//
//  NotificationViewController.swift
//  PWContentExtension
//
//  Created by Andrei Kiselev on 21.12.22..
//  Copyright © 2022 Pushwoosh. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var bestAttemptContent: UNMutableNotificationContent?
    
    var carouselImages : [String] = [String]()
    var currentImagesIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
    }
    
    struct OSCustomNotification {
        let a: AnyHashable
        let i: String
    }
    
    func didReceive(_ notification: UNNotification) {
        
        self.bestAttemptContent = (notification.request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent =  bestAttemptContent {
            
            let userInfo = bestAttemptContent.userInfo as! [String:Any]
            
            if let json = userInfo["u"] {
                let data = json as! String
                do {
                    let res = try convertToDictionary(from: data)
                    let list = res["images"]!.components(separatedBy: ",")
                    self.carouselImages = list
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    // handle error
                }
            }
        }
    }
    
    func convertToDictionary(from text: String) throws -> [String: String] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: String] ?? [:]
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "PWNotificationCarousel.next" {
            self.scrollNextItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        }else if response.actionIdentifier == "PWNotificationCarousel.previous" {
            self.scrollPreviousItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        }else {
            completion(UNNotificationContentExtensionResponseOption.dismissAndForwardAction)
        }
    }
    
    private func scrollNextItem() {
        self.currentImagesIndex == (self.carouselImages.count - 1) ? (self.currentImagesIndex = 0) : ( self.currentImagesIndex += 1 )
        let indexPath = IndexPath(row: self.currentImagesIndex, section: 0)
        self.collectionView.contentInset.right = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.contentInset.left = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
    }
    
    private func scrollPreviousItem() {
        self.currentImagesIndex == 0 ? (self.currentImagesIndex = self.carouselImages.count - 1) : ( self.currentImagesIndex -= 1 )
        let indexPath = IndexPath(row: self.currentImagesIndex, section: 0)
        self.collectionView.contentInset.right = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.contentInset.left = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }
    
}

extension NotificationViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.carouselImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "CarouselNotificationCell"
        self.collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CarouselNotificationCell
        let imagePath = self.carouselImages[indexPath.row]
        cell.configure(imagePath: imagePath)
        cell.layer.cornerRadius = 8.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        let cellWidth = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? (width - 30) : (width - 40)
        return CGSize(width: cellWidth, height: width - 20.0)
    }
    
}
