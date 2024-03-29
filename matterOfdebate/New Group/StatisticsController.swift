//
//  StatisticsController.swift
//  matterOfdebate
//
//  Created by Stefanie Huber on 26.12.17.
//  Copyright © 2017 Gruppe7. All rights reserved.
//

import Foundation
import Charts
import Firebase

class StatisticsController : UIViewController {
    let statisticCalculations = StatisticCalculations()
    private var statsRefUpdateHandle: DatabaseHandle?
    private lazy var statsRef = Constants.refs.statistics

    @IBOutlet weak var proBtn: UIButton!
    @IBOutlet weak var contraBtn: UIButton!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    // MessagesView has a Chat object to display
    var chat: Chat?
    
    let statisticCalculation = StatisticCalculations()
    
    override func viewDidLoad() {
        title = "Statistik"
        
        // set round buttons
        contraBtn.layer.cornerRadius = 10
        proBtn.layer.cornerRadius = 10
        
        // Init charts
        initBarChart()
        initPieChart()
      
        // load statistics list
        loadStatistics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set event handler for to update statistic when firebase child changes
        guard let chat_obj = chat else {return}
        print(chat_obj.id)
        
        // Child is changed maybe, maybe trigger this with an Btn (e.g Refresh Charts)
        statsRef = statsRef.child(chat_obj.id)
        statsRefUpdateHandle = statsRef.observe(.childChanged, with: { (snapshot) -> Void in
            if (snapshot.key == "pro") {
                let pro = snapshot.value as? Int ?? 0
                guard let chatStatistics = self.statisticCalculation.getStatisticByChatId(chat_obj.id) else {return}
                chatStatistics.setPro(pro)
            } else if (snapshot.key == "contra") {
                let contra = snapshot.value as? Int ?? 0
                guard let chatStatistics = self.statisticCalculation.getStatisticByChatId(chat_obj.id) else {return}
                chatStatistics.setContra(contra)
            } else {
                return
            }
            self.updateCharts()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // remove observer
        if let updateHandle = self.statsRefUpdateHandle {
            statsRef.removeObserver(withHandle: updateHandle)
        }
    }
    
    func updateCharts() {
        // show content of shared list
        guard let chat_obj = chat else {return}
        guard let statistic = statisticCalculation.getStatisticByChatId(chat_obj.id) else {return}

        barChartUpdate(Double(statistic.getPro()), Double(statistic.getContra()))
        pieChartUpdate(Double(statistic.getPro()), Double(statistic.getContra()))
    }
    
    
    func loadStatistics() {
        guard let chat_obj = chat else {
            return
        }
        // gets statistic data once, saves it to sharedData list
        let ref = Constants.refs.statistics.child(chat_obj.id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            let contra = value?["contra"] as? Int ?? 0
            let pro = value?["pro"] as? Int ?? 0
            let opinions = value?["users"] as? Dictionary<String, Dictionary<String, String>> ?? [String : [String : String]]()
            let user = opinions[SingletonUser.sharedInstance.user.uid]
            let startOpinion = user?["startOpinion"]
            let currentOpinion = user?["endOpinion"]
            
            let statistic = Statistic(id: snapshot.key, contra: contra, pro: pro, startOpinion: startOpinion, currentOpinion: currentOpinion)
            
            SharedData.statistics.append(statistic)
            self.updateCharts()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func proClick(_ sender: Any) {
        guard let chatObject = chat else {return}
        guard let chatStatistics = statisticCalculation.getStatisticByChatId(chatObject.id) else {return}
        
        if(SharedData.statistics.isEmpty) {
            return
        }
        if(!chatStatistics.votePro()) {
            showDialog()
            return
        }
        
        statisticCalculations.sendStatisticsToDatatbase(chatStatistics)
        statisticCalculations.updateStatistic(chatStatistics)
        updateCharts()
    }
    
    @IBAction func contraClick(_ sender: Any) {
        guard let chatObject = chat else {return}
        guard let chatStatistics = statisticCalculation.getStatisticByChatId(chatObject.id) else {return}
        
        if(SharedData.statistics.isEmpty) {
            return
        }
        if(!chatStatistics.voteContra()) {
            showDialog()
            return
        }
        
        statisticCalculations.sendStatisticsToDatatbase(chatStatistics)
        statisticCalculations.updateStatistic(chatStatistics)
        updateCharts()
    }
    
    func pieChartUpdate(_ pro : Double,_ contra : Double) {
        let entry1 = PieChartDataEntry(value: pro, label: "Pro")
        let entry2 = PieChartDataEntry(value: contra, label: "Contra")
        let dataSet = PieChartDataSet(values: [entry1, entry2], label: "Pro und Contras")
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data

        // show percentages
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        pieChart.data?.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        dataSet.colors = ChartColorTemplates.joyful()
        
        // animation for chart update
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
        
        //This must stay at end of function
        pieChart.notifyDataSetChanged()
    }
    
    func initPieChart() {
        pieChart.chartDescription?.enabled = false
        pieChart.usePercentValuesEnabled = true
        pieChart.legend.enabled = false
        
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
    }
    
    func initBarChart() {
        let formatter = ChartStringFormatter()
        barChart.xAxis.valueFormatter = formatter

        barChart.xAxis.labelCount = 2
        barChart.xAxis.labelPosition = .bottom
        
        // disable gird lines, legend, descritption label
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.enabled = false
        barChart.legend.enabled = false
        barChart.chartDescription?.enabled = false
        
        // Disable user edit
        barChart.doubleTapToZoomEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.scaleXEnabled = false
        barChart.scaleYEnabled = false
        barChart.highlightPerTapEnabled = false
        barChart.highlightPerDragEnabled = false
        
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
    }
    
    func barChartUpdate (_ pro : Double,_ contra : Double) {
        //future home of bar chart code
        let entry1 = BarChartDataEntry(x: 1.0, y: pro)
        let entry2 = BarChartDataEntry(x: 2.0, y: contra)
        let dataSet = BarChartDataSet(values: [entry1, entry2], label: "Pro und Contra")

        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        barChart.barData?.barWidth = Double(0.50)
        
        // set colors
        let green = UIColor(hue: 0.3083, saturation: 1, brightness: 0.8, alpha: 1.0) /* #1ecc00 */
        let red = UIColor(hue: 0, saturation: 1, brightness: 0.92, alpha: 1.0) /* #ea0000 */
        dataSet.colors = [green, red]

        // animation for chart update
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)

        //This must stay at end of function
        barChart.notifyDataSetChanged()
    }
    
    @IBAction func renderCharts() {
        barChartUpdate(0,0)
        pieChartUpdate(0,0)
    }
    
    class ChartStringFormatter: NSObject, IAxisValueFormatter {
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let strings = ["Pro","Contra"]
            return strings[Int(value)-1]
        }
    }
    
    func showDialog() {
        let dialogController = UIAlertController(title: "chenge opinion", message: "You can only click the same opinion one time. Please select the other opinion.", preferredStyle: .alert)
        
        //going back
        let backToTopicView = UIAlertAction(title: "OK", style: .default) { (_) in
        }
        
        //adding the action to dialogbox
        dialogController.addAction(backToTopicView)
        
        self.present(dialogController, animated: true, completion: nil)
    }
}
