//
//  HistoryViewController.swift
//  goly
//
//  Created by Carson Moore on 4/16/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import Charts

class HistoryViewController: UIViewController,  UITextFieldDelegate, ChartViewDelegate {
    // MARK: Properties
    var goal: Goal?
    var dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    @IBOutlet weak var historyChart: BarChartView!
    @IBOutlet weak var drilldownChart: LineChartView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIClickToDismissView!
    
    // Text fields should actually be dates
    let datePickerView = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale // @TODO: Probably figure out where the user is?
        
        setDefaultDates()
        startDateTextField.text = dateFormatter.string(from: startDate as Date)
        endDateTextField.text = dateFormatter.string(from: endDate as Date)
        
        datePickerView.datePickerMode = .date
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        startDateTextField.inputView = datePickerView
        endDateTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: UIControlEvents.valueChanged)
        
        historyChart.delegate = self
        scrollView.canCancelContentTouches = false
        scrollView.keyboardDismissMode = .onDrag

        drilldownChart.delegate = self

        setUpChart()
    }

    //MARK: Do charty stuff
    func setUpChart() {
        historyChart.noDataText = "No Check-Ins available for this goal"
        if let goal = goal {
            navigationItem.title = goal.name
            historyChart.noDataText = "You have not checked in with this goal"
            historyChart.xAxis.valueFormatter = DateAxisFormatter()
            
            plotGoalHistory(goal)
        } else {
            historyChart.noDataText = "Goal did not load!" // should never happen!?
        }
        
    }
    
    func plotGoalHistory(_ goal: Goal) {
        // Prep the aggregations
        let (dates, values) = aggregateCheckIns(goal)
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        let chartData = BarChartData(dataSet: chartDataSet)
        historyChart.data = chartData
        if let formatter = historyChart.xAxis.valueFormatter as? DateAxisFormatter {
            formatter.dates = dates
        }
        
        // Formatting
        formatChart(historyChart, yMax: Double(values.max() ?? 0))
        chartDataSet.colors = values.map { $0 < goal.target ? UIColor.white : UIColor.black }
        chartDataSet.barBorderColor = UIColor.black
        chartDataSet.barBorderWidth = 1
        
        let passing = String((values.map { $0 >= goal.target ? 1 : 0 }).reduce(0, +))
        let cnt = values.count
        let pluralSuffix = cnt > 1 ? "s" : ""
        
        summaryLabel.text = "Goal accomplished " + passing + " out of " + String(cnt) + " " + Frequency.nounify(goal.frequency) + pluralSuffix
        
        hideDrilldownChart() // Rehide the drilldown if it's not currently hidden
        historyChart.notifyDataSetChanged()
    }
    
    // Sum up the checkIns according to their goal timeframe; return the x and y labels
    func aggregateCheckIns(_ goal: Goal) -> ([String], [Int]) {
        let timeframes = Timeframe.fromRange(startDate as Date, endDate: endDate as Date, frequency: goal.frequency)
        var values = [Int](repeating: 0, count: timeframes.count)
        
        if (timeframes.count > 0) {
            // Rely on the min / max timeframe dates, not min / max dates set
            let minStartDate = timeframes.first!.startDate
            let maxEndDate = timeframes.last!.endDate
            // timeframes are organized ascending and check-ins descending; we can flip one of the two for some
            // additional effeciency gains here as we iterate.
            let checkIns = goal.checkIns.reversed()
            var tfIndex = 0 // We can keep track of which TF we're in and never look lower than that
            for checkIn in checkIns {
                // Handle cases where we need to continue iterating or end iteration
                if (checkIn.timeframe.endDate.timeIntervalSince1970 <= (minStartDate?.timeIntervalSince1970)!) { continue }
                if (checkIn.timeframe.startDate.timeIntervalSince1970 > (maxEndDate?.timeIntervalSince1970)!) { break }
                
                // All other cases are guaranteed to fit into a timeframe
                let citf = checkIn.timeframe
                // Figure out which index of the timeframe array this checkIn falls into
                for i in tfIndex ..< timeframes.count {
                    let tf = timeframes[i]
                    if (citf.startDate.timeIntervalSince1970 >= tf.startDate.timeIntervalSince1970 && citf.startDate.timeIntervalSince1970 < tf.endDate.timeIntervalSince1970) {
                        // We've found the right one!
                        tfIndex = i
                        values[tfIndex] += checkIn.value
                        break
                    }
                }
            }
        }
        
        return (timeframes.map { $0.toChartString() }, values)
        
    }
    
    // Format a chart by eliminating grid lines, decimals, right axis, etc.
    func formatChart(_ chart: BarLineChartViewBase, yMax: Double) {
        let axisFormatter = DefaultAxisValueFormatter()
        let formatter = DefaultValueFormatter()
        formatter.decimals = 0
        axisFormatter.decimals = 0
        // formatter.minimumFractionDigits = 0 DEBUG?
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelCount = [chart.data!.entryCount, 10].min()! // Is there a default way to do spacing?
        chart.xAxis.gridColor = UIColor.clear
        chart.leftAxis.axisMinimum = 0.0
        chart.leftAxis.valueFormatter = axisFormatter
        chart.leftAxis.granularity = 1 // Sets a minimum granularity, but allows for higher granularities
        chart.leftAxis.axisMaximum = [1.0, yMax * 1.1].max()!
        chart.leftAxis.gridColor = UIColor.clear
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.data!.setValueFormatter(formatter)
        if (chart.data!.entryCount > 20) { chart.data!.setDrawValues(false) }
        chart.chartDescription!.text = ""
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false

        let limit = ChartLimitLine(limit: Double(goal!.target), label: "")
        limit.lineColor = UIColor.black
        limit.lineDashLengths = [4.0, 2.0]
        chart.leftAxis.addLimitLine(limit)
    }
    
    // MARK: Drilldown chart
    func plotDrilldown(_ xVals: [String], yVals: [Int]) {
        showDrilldownChart()
        let goal = self.goal!
        var dataEntries = [BarChartDataEntry]()
        var runningTotal = 0.0
        var dataPointLabelColors = [UIColor]()

        // Initialize with a 0-point:
        dataEntries.append(BarChartDataEntry(x: -0.5, y: 0.0))
        dataPointLabelColors.append(UIColor.clear)
        for i in 0..<yVals.count {
            let newRt = runningTotal + Double(yVals[i])
            dataPointLabelColors.append(newRt == runningTotal ? UIColor.clear : UIColor.black)
            runningTotal = newRt
            let dataEntry = BarChartDataEntry(x: Double(i), y: runningTotal) // Plot in the middle of the date / daterange
            dataEntries.append(dataEntry)
        }

        // And top it off with a buffer point:
        dataEntries.append(BarChartDataEntry(x: Double(xVals.count) - 0.5, y: runningTotal))
        dataPointLabelColors.append(UIColor.clear)
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        let chartData = LineChartData(dataSet: chartDataSet)
        let xAxisFormatter = DateAxisFormatter()
        chartDataSet.colors = [UIColor.black]
        chartDataSet.circleColors = [UIColor.black]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = UIColor.black
        chartDataSet.fillAlpha = 1.0
        chartDataSet.valueColors = dataPointLabelColors
        xAxisFormatter.dates = xVals

        drilldownChart.xAxis.valueFormatter = xAxisFormatter
        drilldownChart.data = chartData
        formatChart(drilldownChart, yMax: [runningTotal, Double(goal.target)].max()!)
        drilldownChart.xAxis.setLabelCount([xVals.count, 4].min()!, force: true) // Is there a default way to do spacing?
        drilldownChart.notifyDataSetChanged()
    }
    
    func hideDrilldownChart() {
        drilldownChart.isHidden = true
        for c in contentView.constraints {
            if (c.identifier == "drilldownHeight") {
                c.constant = 172.0
                contentView.layoutIfNeeded()
            }
        }
    }
    
    func showDrilldownChart() {
        drilldownChart.isHidden = false
        for c in contentView.constraints {
            if (c.identifier == "drilldownHeight") {
                c.constant = 172.0
                contentView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: text fields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the picker view
        contentView.currentTextField = nil
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contentView.currentTextField = textField // Used by handleDatePicker
        if let date = dateFormatter.date(from: textField.text!) {
            datePickerView.date = date
        }
        
        if (textField == startDateTextField) { datePickerView.maximumDate = endDate as Date }
        else { datePickerView.maximumDate = NSDate() as Date }
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        var shouldPlot = false // only replot if something has actually changed
        let date = sender.date
        let ctf = contentView.currentTextField!
        ctf.text = dateFormatter.string(from: date)
        if (ctf == startDateTextField) {
            shouldPlot = (startDate as Date != date)
            startDate = date
        }
        if (ctf == endDateTextField) {
            shouldPlot = (endDate as Date != date)
            endDate = date
            if (startDate.timeIntervalSince1970 > endDate.timeIntervalSince1970) {
                startDate = endDate
                startDateTextField.text = dateFormatter.string(from: startDate as Date)
            }
        }
        
        if (shouldPlot) { setUpChart() }
    }
    
    // MARK: Chart view delegate
    // handle interactions on clicked bars in order to drilldown
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let goal = self.goal!
        if (Frequency.equals(goal.frequency, rhs: goal.checkInFrequency) || (chartView == historyChart && (entry.y as Double) == 0.0) || chartView == drilldownChart) {
            // Can't really drill down into 0, nor can you drill down into something that
            // only has one check in.... but you can open up the relevant check-in:
            let date = getDateFromEntry(chart: chartView, entry: entry)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "CheckIn") as! CheckInViewController
            controller.goal = goal
            controller.date = date
            controller.autoPopKeyboard = false

            // This is the only way I can really find that works to get the controller to show up in the nav controller as expected
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = appDelegate.window!
            let rvc = window.rootViewController as! UINavigationController
            rvc.pushViewController(controller, animated: false)

            return
        }

        // Getting the date and timeframe will allow us to grab any checkIns for this goal
        let date = getDateFromEntry(chart: historyChart, entry: entry)
        let timeframe = Timeframe(frequency: goal.frequency, now: date)
        var cis = [Date: Int]()
        // Iterating backwards...
        for checkIn in goal.checkIns {
            if (checkIn.timeframe.endDate.timeIntervalSince1970 <= timeframe.startDate.timeIntervalSince1970) {
                break
            }
            
            if (checkIn.timeframe.startDate.timeIntervalSince1970 >= timeframe.endDate.timeIntervalSince1970) {
                continue
            }
            
            cis[checkIn.timeframe.startDate] = checkIn.value
        }
        
        let citfs = timeframe.subTimeframes(subFrequency: goal.checkInFrequency)
        let xVals = citfs.map{ $0.toChartString() }
        let yVals = citfs.map{ cis[$0.startDate] ?? 0 }
        plotDrilldown(xVals, yVals: yVals)
    }
    
    // MARK: Defaults
    func setDefaultDates() {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        endDate = cal.startOfDay(for: Date())
        if let goal = goal {
            switch goal.frequency {
            case .Daily:
                startDate = cal.date(byAdding: DateComponents(day: -7), to: endDate)!
            case .Weekly:
                startDate = cal.date(byAdding: DateComponents(day: -56), to: endDate)!
            case .Monthly:
                startDate = cal.date(byAdding: DateComponents(month: -12), to: endDate)!
            case .Quarterly:
                startDate = cal.date(byAdding: DateComponents(month: -24), to: endDate)!
            case .Yearly:
                startDate = cal.date(byAdding: DateComponents(year: -3), to: endDate)!
            }
            
            // Limit the start to the oldest check-in.  Goals may have check-ins older than the created date
            if let last = goal.checkIns.last {
                if last.timeframe.startDate.timeIntervalSince1970 > startDate.timeIntervalSince1970 {
                    startDate = last.timeframe.startDate
                }
            }
        }
    }

    // MARK: helpers
    func getDateFromEntry(chart: ChartViewBase, entry: ChartDataEntry) -> Date {
        var date = Date()
        if let xAxisFormatter = chart.xAxis.valueFormatter as? DateAxisFormatter {
            let strDaterange = xAxisFormatter.dates![Int(entry.x)]
            let startDate = strDaterange.components(separatedBy: " - ")[0]
            date = Timeframe.getDateFormatter().date(from: startDate)!
        }

        return date
    }
}
