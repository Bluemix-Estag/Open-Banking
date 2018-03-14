//
//  ChartViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 14/03/18.
//  Copyright © 2018 Rabah Zeineddine. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {

    @IBOutlet weak var pieChart: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pieChartUpdate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func pieChartUpdate(){
        
        // 10,000
        // 30
        let entry1 = PieChartDataEntry(value: 1500.00 , label: "15%")
        let entry2 = PieChartDataEntry(value: 3500.00, label: "35%")
        let entry3 = PieChartDataEntry(value: 5000 , label: "50%")
        
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: " ")
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueColors = [UIColor.black]
        dataSet.formSize = CGFloat(22)
        let data = PieChartData(dataSet: dataSet)
        
        pieChart.data = data
        
        
//        pieChart.chartDescription?.font =  UIFont(name: "Fatura", size: 12)!
        pieChart.entryLabelFont?.withSize(CGFloat(14))
        pieChart.chartDescription?.xOffset = pieChart.frame.width + 30
        pieChart.chartDescription?.yOffset = pieChart.frame.height * (2/3)
        pieChart.chartDescription?.textAlign = NSTextAlignment.left
        
        pieChart.chartDescription?.text = "test"
        
        // All other additions to this function will go here
        
        
        pieChart.notifyDataSetChanged()
    }

}
