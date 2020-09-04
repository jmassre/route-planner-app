//
//  ViewController.swift
//  Route Planner
//
//  Created by Joey Massre on 8/10/20.
//  Copyright © 2020 Joey Massre. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    

       

    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var viewTop: UIView! //full view
    @IBOutlet weak var scrollView: UIScrollView! //scrollview
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var removeLocationButton: UIButton!
    @IBOutlet weak var calculateRouteButton: UIButton!
    
    @IBOutlet weak var roundTripSwitch: UISwitch!
    @IBOutlet weak var endPointSwitch: UISwitch!
    
    @IBOutlet weak var endPointLabel: UILabel!
    @IBOutlet weak var lastTextBox: UITextField!
    //constraints for last text box
    @IBOutlet weak var topToBottomText: NSLayoutConstraint!
    @IBOutlet weak var topToBottomText2: NSLayoutConstraint!
    //constraints for end point label
    @IBOutlet weak var topToBottomLabel: NSLayoutConstraint!
    @IBOutlet weak var topToBottomLabel2: NSLayoutConstraint!
    
    //second point
    @IBOutlet weak var secondPointText: UITextField!
    @IBOutlet weak var otherPointTrailing: NSLayoutConstraint!
    @IBOutlet weak var startPointText: UITextField!
    
    //array of the other point labels
    var otherLabels = [UILabel]()
    

    //start of new constraints for end point label
    var topToBottomText2Int: CGFloat = 249
    var topToBottomTextInt: CGFloat = 249
    var topToBottomLabelInt: CGFloat = 254
    var topToBottomLabel2Int: CGFloat = 254
    
    
    var allLocations = [String]() //array of all locations
    var midLocations = [UITextField]() //array of locations between first and last points
    
    var constraintsLast = [NSLayoutConstraint]() //array of constraints for the lext box to be able to deactivate when a new location is added
    
    var isRound = false //round trip set to false by default
    var isEnd = true //end point set to true by default
    
    let xPos : CGFloat = 10 //new point x pos
    var yPos : CGFloat = 202 //new point y pos
    
    var textFieldNums : Int = 0 //amount of new text fields
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //keep the round trip switch off
        roundTripSwitch.setOn(false, animated: true)
        
        //append constraintsLast array to deactivate if needed
        constraintsLast.append(contentsOf: [topToBottomText, topToBottomText2, topToBottomLabel, topToBottomLabel2])
        
        //make buttons round
        addLocationButton.layer.cornerRadius = 10
        calculateRouteButton.layer.cornerRadius = 10
        removeLocationButton.layer.cornerRadius = 10
        
        
        midLocations.append(secondPointText) //add location to mid location
        
        
       
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.frame.height) //set scrollview size
        
    }
    
    //when button tapped
    @IBAction func addLocationButtonTapped(_ sender: Any) {
        //cap places at 15
        if textFieldNums >= 12{
            return
        }
        else{
            textFieldNums += 1
            
            
            yPos += 47 //new location text box goes here
            
            //new text field
            let tf = UITextField()
            tf.frame = CGRect(x: 135, y: yPos, width: secondPointText.frame.width, height: 34)
            tf.borderStyle = .roundedRect
            tf.font = UIFont.systemFont(ofSize: 14.0)
            midLocations.append(tf) //add to mid locations
            self.viewTop.addSubview(tf)
            
            //new label
            let otherLabel = UILabel()
            otherLabel.text = "Other Point:"
            otherLabel.frame = CGRect(x: 20, y: yPos+5, width: 104, height: 24)
            otherLabel.font = UIFont.systemFont(ofSize: 19.0)
            otherLabels.append(otherLabel)
            
            self.viewTop.addSubview(otherLabel)

            //deactivate constraints for last location and move down
            NSLayoutConstraint.deactivate(constraintsLast)
            constraintsLast.removeAll()
         
            topToBottomTextInt+=47
            topToBottomText2Int+=47
                
            topToBottomLabel2Int+=47
            topToBottomLabelInt+=47
            
            
            
            topToBottomText = lastTextBox.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomTextInt)
            topToBottomText2 = lastTextBox.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomText2Int)
            
            
            topToBottomLabel = endPointLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomLabelInt)
            
            topToBottomLabel2 = endPointLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomLabel2Int)
            
            constraintsLast.append(contentsOf: [topToBottomText, topToBottomText2, topToBottomLabel, topToBottomLabel2, ])
            
            //activate the new constraints
            NSLayoutConstraint.activate(constraintsLast)
            
            //change scrollview size in order to scroll if needed
            if endPointLabel.frame.midY >= scrollView.contentSize.height-100{
                scrollView.contentSize.height+=40

            }
            
            
        }
        
    }

    //when remove location button was tapped
    @IBAction func removeLocationButtonTapped(_ sender: Any) {
        //if there are locations to be removed
        if otherLabels.count>0{
            
            
            yPos-=47 //move down new y pos
            textFieldNums-=1 //lessen amount of text fields
            
            //remove in every array
            midLocations[midLocations.count-1].removeFromSuperview()
            midLocations.remove(at: midLocations.count-1)
            otherLabels[otherLabels.count-1].removeFromSuperview()
            otherLabels.remove(at: otherLabels.count-1)
            
            //deactivate the last location's constraints
            NSLayoutConstraint.deactivate(constraintsLast)
               constraintsLast.removeAll()
            
                //change the constraints to be higher up on scrollview
               topToBottomTextInt-=47
               topToBottomText2Int-=47
                   
               topToBottomLabel2Int-=47
               topToBottomLabelInt-=47
               
               
               
               topToBottomText = lastTextBox.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomTextInt)
               topToBottomText2 = lastTextBox.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomText2Int)
               
               
               topToBottomLabel = endPointLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomLabelInt)
               
               topToBottomLabel2 = endPointLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topToBottomLabel2Int)
               
               constraintsLast.append(contentsOf: [topToBottomText, topToBottomText2, topToBottomLabel, topToBottomLabel2, ])
               
            
            NSLayoutConstraint.activate(constraintsLast) //activate it
            scrollView.contentSize.height-=40 //change scrollview length
        }
       
        
        
    }
    
    //when user toggles the end point switch
    @IBAction func endPointToggled(_ sender: UISwitch) {
        changeEndLabel(isEnd: sender.isOn) //change end label
        
        //if it's flipped on
        if sender.isOn{
            isEnd = true //end location is true
            roundTripSwitch.setOn(false, animated: true) //flip round trip off
            isRound = false //round trip false
        }
        //if it's flipped off
        else{
            isEnd = false //end location is false
        }
        
    }
    
    //changes the last label
    func changeEndLabel(isEnd: Bool){
        //if specific end point
        if isEnd == true{
            endPointLabel.text = "End Point:"
            
        }
        //if not specific end point
        else{
            endPointLabel.text = "Other Point:"
        }
    }
    
    @IBAction func roundTripToggled(_ sender: UISwitch) {
        if sender.isOn{
            self.isRound = true
            endPointSwitch.setOn(false, animated: true)
            isEnd = false
            changeEndLabel(isEnd: isEnd)
        }
        else{
            self.isRound = false
        }
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        allLocations.append(startPointText.text!)
        
        for location in midLocations{
            allLocations.append(location.text!)
        }
        allLocations.append(lastTextBox.text!)
        
        for location in allLocations{
            if location == ""{
                print("hey")
                return
            }
        }

        let newVC: SecondViewController = segue.destination as! SecondViewController
        
        newVC.allLocations = allLocations
        
        newVC.isRound = isRound
        
        newVC.isEnd = isEnd
        
        self.allLocations.removeAll()
        newVC.activityIndicator = activityIndicator
        
    }
    

    @IBAction func calculateRouteTapped(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
          self.performSegue(withIdentifier: "displayRoute", sender: nil)
        })
        

        
    }
    
}

