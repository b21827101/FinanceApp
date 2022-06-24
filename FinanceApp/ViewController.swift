//
//  ViewController.swift
//  FinanceApp
//
//  Created by İlayda Atmaca on 17.06.2022.
//

import UIKit

final class ViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UITextViewDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var coins: [Coin] = []
    

    func fetchCoins(completionHandler: @escaping ([Coin]) -> Void) {
        
        guard let url = URL(string: "https://api.coinstats.app/public/v1/coins") else { return}
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
            return
          }

          if let data = data,
            let coinResult = try? JSONDecoder().decode(Welcome.self, from: data) {
              var myCoins : [Coin] = []
              
              for i in coinResult.coins{
                  let url = URL(string: i.icon)
                  let data = try? Data(contentsOf: url!)

                  var myCoinImage = UIImage()
                  if let imageData = data {
                      myCoinImage = UIImage(data: imageData)!
                  }
                  
                  myCoins.append(Coin(label: i.name, image: myCoinImage, shortening: i.symbol, price: String(i.price), buttonID: i.rank))
              }
              
              completionHandler(myCoins)
              
          }
        })
        task.resume()
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCoins{ [weak self] coins in
                self?.coins = coins
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                  }
        }
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    @IBAction func didTap(_ sender: UIButton){
        print(sender.tag)
        if let i = coins.firstIndex(where: { $0.buttonID == sender.tag }) {
            ViewDetailsController.tapCoin = coins[i]
        }
        performSegue(withIdentifier: "detailView", sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else{
            return
        }
    }
    
    
    
 }

// MARK: - UICollectionViewDataSource
extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCollectionViewCell", for: indexPath) as! CoinCollectionViewCell
        cell.setup(with: coins[indexPath.row])
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coins.count
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(coins[indexPath.row].label)
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat.halfSizeOfScreen, height: CGFloat.halfSizeOfScreen)
    }
}

extension ViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(coins[indexPath.row].label)
    }
    
    
    
}
