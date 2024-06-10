//
//  MealCell.swift
//  KcalLogger
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var centerBall: UIView!
    @IBOutlet weak var bottomBar: UIView!

    @IBOutlet weak var mealDescription: UILabel!
    @IBOutlet weak var mealTime: UILabel!
    @IBOutlet weak var mealCalories: UILabel!
    
    static let minimumHeight = CGFloat(50)

    var meal: Meal! {
        didSet {
           updateMeal()
        }
    }

    var hasExceededKcal: Bool! {
        didSet {
            DispatchQueue.main.async {
                self.topBar.backgroundColor = self.hasExceededKcal ? .red : .green
                self.centerBall.backgroundColor = self.hasExceededKcal ? .red : .green
                self.bottomBar.backgroundColor = self.hasExceededKcal ? .red : .green
            }
        }
    }

    var mealPosition: MealPosition! {
        didSet {
            DispatchQueue.main.async {
                self.topBar.isHidden = self.mealPosition == MealPosition.first || self.mealPosition == MealPosition.only
                self.bottomBar.isHidden = self.mealPosition == MealPosition.last || self.mealPosition == MealPosition.only
            }
        }
    }

    func updateMeal() {
        guard let meal = meal else { return }

        mealDescription.text = meal.description
        mealTime.text = meal.date.getHoursMinutes()
        mealCalories.text = "\(meal.kcalAmount) kCal"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
//        DispatchQueue.main.async {
//            self.centerBall.layer.cornerRadius = 6
//            self.centerBall.layer.borderColor = UIColor.white.cgColor
//            self.centerBall.layer.borderWidth = 2
//        }
    }

    override func prepareForReuse() {
        mealDescription.text = ""
        mealTime.text = ""
        mealCalories.text = ""
    }
}
