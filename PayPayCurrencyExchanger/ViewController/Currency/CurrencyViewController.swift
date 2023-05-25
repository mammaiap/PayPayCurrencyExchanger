//
//  CurrencyViewController.swift
//  PayPayCurrencyExchanger
//
//  Created by muthulingam on 22/05/23.
//

import UIKit
import Combine

// MARK: - Main View Controller which consists of all the UIObjects

class CurrencyViewController: UIViewController {
    
    //MARK: UIProperty
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var countryContainerView: UIView!
    
    @IBOutlet weak var countryTableView: UITableView!
    
    @IBOutlet weak var exchangeCollectionView: UICollectionView!
    
    //MARK: Property
    let viewModel = CurrencyViewModel()
    private var canncellable = Set<AnyCancellable>()

    //MARK: Life cycler
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("CurrencyViewController viewDidLoad")
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        configureLayout()
        setupObservers()   
        
    }
    
    func title() ->String{
        return "PayPay CurrencyExchanger"
    }
    
    @objc
    func amountTextfieldFinishEditing() {
        amountTextField.resignFirstResponder()
        if let text = amountTextField.text {
            if(text != ""){
                viewModel.amount = text
            }
            
        }
    }
    
    //MARK: IBAction
    @IBAction func onDropDown(_ sender: Any) {
        
        if(countryContainerView.isHidden)
        {
            countryContainerView.isHidden = false
        }else{
            countryContainerView.isHidden = true
        }
        
    }
}

private extension CurrencyViewController {
    
    //MARK: Setup Observers
    func setupObservers() {
        viewModel.$currencyCellVM.sink { [weak self] _ in
            print("sink")
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.exchangeCollectionView.reloadData()
                self.countryTableView.reloadData()
            }
        }.store(in: &canncellable)
    }
    
    //MARK: UIObjects Config
    func configureLayout() {
        
        self.countryTableView.delegate = self
        self.countryTableView.dataSource = self
        self.countryTableView.tableFooterView = UIView(frame: CGRectZero)
        self.countryTableView.layer.masksToBounds = true
        self.countryContainerView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.25).cgColor
        self.countryContainerView.layer.shadowOffset = CGSizeMake(0, 2.0)
        self.countryContainerView.layer.shadowOpacity = 1.0
        self.countryContainerView.layer.shadowRadius = 3.0
        
        self.countryTableView.reloadData()
        
        self.countryContainerView.isHidden = true
        
        self.exchangeCollectionView.dataSource = self
        self.exchangeCollectionView.delegate = self
        self.exchangeCollectionView.register(UINib(nibName: "ExchangeCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ExchangeCollectionViewCell")
        
        
        amountTextField.keyboardType = .decimalPad
        let toolbar: UIToolbar = UIToolbar(
            frame: .init(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 50)
        )
        toolbar.barStyle = .default
        
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(amountTextfieldFinishEditing)
        )
        
        let items = [space, done]
        toolbar.items = items
        toolbar.sizeToFit()
        amountTextField.inputAccessoryView = toolbar
        
        
    }
     
}

//MARK: UITableViewDataSource UITableViewDelegate
extension CurrencyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        viewModel.pickerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.contentView.frame = CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero

        let borderLeft = UIView.init(frame: CGRectMake(0, 0, 1, cell.contentView.bounds.size.height))
        borderLeft.backgroundColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1)
        
        let borderRight = UIView.init(frame: CGRectMake(cell.contentView.bounds.size.width - 1, 0, 1, cell.contentView.bounds.size.height))
        borderRight.backgroundColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1)
        
      
        cell.addSubview(borderLeft)
        cell.addSubview(borderRight)
        cell.textLabel?.font = UIFont(name: "System-Bold", size: 20)
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.textAlignment = .center
        
        let dataSelected = viewModel.pickerData[indexPath.row]
        
        cell.textLabel?.text = dataSelected
        
        cell.backgroundColor = .white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        countryContainerView.isHidden = true
        
        let dataSelected = viewModel.pickerData[indexPath.row]
        
        countryTextField.resignFirstResponder()

        countryTextField.text = dataSelected
        
        viewModel.pickedCountry = dataSelected
        
    }
}

//MARK: UICollectionViewDelegateFlowLayout UICollectionViewDataSource UICollectionViewDelegate
extension CurrencyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currencyCellVM.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVM = viewModel.currencyCellVM[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeCollectionViewCell", for: indexPath) as! ExchangeCollectionViewCell
        
        cell.setup(cellVM)
        return cell
    }
    
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
     }
    
}

//MARK: UITextFieldDelegate
extension CurrencyViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        if textField == amountTextField {
            textField.text = nil
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        print("textFieldDidEndEditing")
    }
}
