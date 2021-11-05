//
//  ViewController.swift
//  iOS_Practical_Test_Anamul
//
//  Created by Anamul Habib on 10/30/21.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var movieInfoTableView: UITableView!
    
    private var searchedResults: [SearchedMovieResult]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func searchQueryTyped(_ sender: UITextField) {
        
        if sender.text?.isEmpty == false {
            
            WebServiceHandler.shared.fetchMovie(query: sender.text, onSuccess: { (response) in
                
                if response.results?.count ?? 0 > 0{
                    self.searchedResults = response.results
                    self.movieInfoTableView.delegate = self
                    self.movieInfoTableView.dataSource = self
                    self.movieInfoTableView.reloadData()
                }
                
            }, onFailure: { ( error) in
                self.showDialog(title: nil, message: "Error Occured !", onDefaultActionButtonTap: nil)
            }, shouldShowLoader: false)
        }
    }
    
    private func showDialog(title: String?, message: String, defaultActionButtonTitle: String = "OK", onDefaultActionButtonTap defaultButtonAction: (()->())?){
        
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: defaultActionButtonTitle, style: .default, handler: { action in
            if let defaultButtonAction = defaultButtonAction{
                defaultButtonAction()
            }
        }))
        
        alert.view.tintColor = view.tintColor
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:))))
    }
    
    @objc private func tapDetected(_ tapRecognizer: UITapGestureRecognizer?) {
        
        view.endEditing(true)
        if let tapRecognizer = tapRecognizer {
            view.removeGestureRecognizer(tapRecognizer)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchedResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieInfoTableViewCell.reuseIdentifier, for: indexPath) as! MovieInfoTableViewCell
        
        let movie = searchedResults?[indexPath.row]
        
        cell.movieNameLabel.text = movie?.title
        cell.movieOverviewLabel.text = movie?.overview
        
        cell.moviePosterImageView.setImageFromURl(imageUrl: "http://image.tmdb.org/t/p/w500" + (movie?.posterPath ?? ""), cacheEnabled: true)
        
        return cell
    }
}

class MovieInfoTableViewCell: UITableViewCell{
    
    static let reuseIdentifier = "movieInfoTableViewCellId"
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
}

