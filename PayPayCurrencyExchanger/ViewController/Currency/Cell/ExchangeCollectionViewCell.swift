//
//  ExchangeCollectionViewCell.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import UIKit

class ExchangeCollectionViewCell: UICollectionViewCell {
    
    //MARK: UIProperty
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    //MARK: Method
    func setup(_ viewModel: ExchangeCollectionViewCellVM) {
        self.countryLabel.text = viewModel.country
        self.amountLabel.text = viewModel.amount
        
      let image = UIImage.init(named: viewModel.country.lowercased())
      if let newimage = image{
          self.imageView.image = newimage
      }else{
         
      }
        
    }
    
}
