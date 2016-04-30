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
    var dateFormatter = NSDateFormatter()
    var startDate = NSDate()
    var endDate = NSDate()
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
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // @TODO: Probably figure out where the user is?
        
        setDefaultDates()
        startDateTextField.text = dateFormatter.stringFromDate(startDate)
        endDateTextField.text = dateFormatter.stringFromDate(endDate)
        
        datePickerView.datePickerMode = .Date
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        startDateTextField.inputView = datePickerView
        endDateTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), forControlEvents: UIControlEvents.ValueChanged)
        
        historyChart.delegate = self
        scrollView.canCancelContentTouches = false
        scrollView.keyboardDismissMode = .OnDrag
        
        setUpChart()
    }
    
    //MARK: Do charty stuff
    func setUpChart() {
        historyChart.noDataText = "No Check-Ins available for this goal"
        if let goal = goal {
            navigationItem.title = goal.name
            historyChart.noDataTextDescription = "You have not checked in with this goal"
            
            plotGoalHistory(goal)
        } else {
            historyChart.noDataTextDescription = "Goal did not load!" // should never happen!?
        }
        
    }
    
    func plotGoalHistory(goal: Goal) {
        // Prep the aggregations
        let (dates, values) = aggregateCheckIns(goal)
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(value: Double(values[i]), xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
        historyChart.data = chartData
        
        // Formatting
        formatChart(historyChart, yMax: Double(values.maxElement() ?? 0.0))
        chartDataSet.colors = values.map { $0 < goal.target ? UIColor.whiteColor() : UIColor.blackColor() }
        chartDataSet.barBorderColor = UIColor.blackColor()
        chartDataSet.barBorderWidth = 1
        
        let passing = String((values.map { $0 >= goal.target ? 1 : 0 }).reduce(0, combine: +))
        let cnt = values.count
        let pluralSuffix = cnt > 1 ? "s" : ""
        
        summaryLabel.text = "Goal accomplished " + passing + " out of " + String(cnt) + " " + Frequency.nounify(goal.frequency) + pluralSuffix
        
        drilldownChart.hidden = true // Rehide the drilldown if it's not currently hidden
    }
    
    // Sum up the checkIns according to their goal timeframe; return the x and y labels
    func aggregateCheckIns(goal: Goal) -> ([String], [Int]) {
        let timeframes = Timeframe.fromRange(startDate, endDate: endDate, frequency: goal.frequency)
        var values = [Int](count: timeframes.count, repeatedValue: 0)
        
        if (timeframes.count > 0) {
            // Rely on the min / max timeframe dates, not min / max dates set
            let minStartDate = timeframes.first!.startDate
            let maxEndDate = timeframes.last!.endDate
            // timeframes are organized ascending and check-ins descending; we can flip one of the two for some
            // additional effeciency gains here as we iterate.
            let checkIns = goal.checkIns.reverse()
            var tfIndex = 0 // We can keep track of which TF we're in and never look lower than that
            for checkIn in checkIns {
                // Handle cases where we need to continue iterating or end iteration
                if (checkIn.timeframe.endDate.timeIntervalSince1970 <= minStartDate.timeIntervalSince1970) { continue }
                if (checkIn.timeframe.startDate.timeIntervalSince1970 > maxEndDate.timeIntervalSince1970) { break }
                
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
        
        return (timeframes.map { $0.toString() }, values)
        
    }
    
    // Format a chart by eliminating grid lines, decimals, right axis, etc.
    func formatChart(chart: BarLineChartViewBase, yMax: Double) {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        chart.xAxis.labelPosition = .Bottom
        chart.xAxis.gridColor = UIColor.clearColor()
        chart.leftAxis.axisMinValue = 0.0
        chart.leftAxis.valueFormatter = formatter
        chart.leftAxis.granularity = 1 // Sets a minimum granularity, but allows for higher granularities
        chart.leftAxis.axisMaxValue = [1.0, yMax * 1.1].maxElement()!
        chart.leftAxis.gridColor = UIColor.clearColor()
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.data!.setValueFormatter(formatter)
        if (chart.data!.xValCount > 20) { chart.data!.setDrawValues(false) }
        chart.descriptionText = ""
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .Linear)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        let limit = ChartLimitLine(limit: Double(goal!.target), label: "")
        limit.lineColor = UIColor.blackColor()
        limit.lineDashLengths = [4.0, 2.0]
        chart.leftAxis.addLimitLine(limit)
    }
    
    // MARK: Drilldown chart
    func plotDrilldown(xVals: [String], yVals: [Int]) {
        drilldownChart.hidden = false
        let goal = self.goal!
        var dataEntries = [BarChartDataEntry]()
        var runningTotal = 0.0
        var dataPointLabelColors = [UIColor]()
        for i in 0..<yVals.count {
            let newRt = runningTotal + Double(yVals[i])
            dataPointLabelColors.append(newRt == runningTotal ? UIColor.clearColor() : UIColor.blackColor())
            runningTotal = newRt
            let dataEntry = BarChartDataEntry(value: runningTotal, xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "")
        let chartData = LineChartData(xVals: xVals, dataSet: chartDataSet)
        drilldownChart.data = chartData
        formatChart(drilldownChart, yMax: [runningTotal, Double(goal.target)].maxElement()!)
        chartDataSet.colors = [UIColor.blackColor()]
        chartDataSet.circleColors = [UIColor.blackColor()]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = UIColor.blackColor()
        chartDataSet.fillAlpha = 1.0
        chartDataSet.valueColors = dataPointLabelColors
    }
    
    // MARK: text fields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the picker view
        contentView.currentTextField = nil
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        contentView.currentTextField = textField // Used by handleDatePicker
        if let date = dateFormatter.dateFromString(textField.text!) {
            datePickerView.date = date
        }
        
        if (textField == startDateTextField) { datePickerView.maximumDate = endDate }
        else { datePickerView.maximumDate = NSDate() }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        var shouldPlot = false // only replot if something has actually changed
        let date = sender.date
        let ctf = contentView.currentTextField!
        ctf.text = dateFormatter.stringFromDate(date)
        if (ctf == startDateTextField) {
            shouldPlot = (startDate != date)
            startDate = date
        }
        if (ctf == endDateTextField) {
            shouldPlot = (endDate != date)
            endDate = date
            if (startDate.timeIntervalSince1970 > endDate.timeIntervalSince1970) {
                startDate = endDate
                startDateTextField.text = dateFormatter.stringFromDate(startDate)
            }
        }
        
        if (shouldPlot) { setUpChart() }
    }
    
    // MARK: Chart view delegate
    // handle interactions on clicked bars in order to drilldown
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let goal = self.goal!
        
        if (goal.frequency == goal.checkInFrequency || entry.value == 0.0) {
            return // Can't drilldown into a daily view; can't really drilldown into 0
        }
        
        // Getting the date and timeframe will allow us to grab any checkIns for this goal
        let date = Timeframe.getDateFormatter().dateFromString(chartView.data!.xVals[entry.xIndex]!)!
        let timeframe = Timeframe(frequency: goal.frequency, now: date)
        
        var cis = [NSDate: Int]()
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
        
        let citfs = Timeframe.fromRange(timeframe.startDate, endDate: timeframe.endDate, frequency: goal.checkInFrequency)
        let df = Timeframe.getDateFormatter()
        let xVals = citfs.map{ df .stringFromDate($0.startDate) }
        let yVals = citfs.map{ cis[$0.startDate] ?? 0 }
        plotDrilldown(xVals, yVals: yVals)
    }
    
    // MARK: Defaults
    func setDefaultDates() {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let opts = NSCalendarOptions(rawValue: 0)
        endDate = cal.startOfDayForDate(NSDate())
        if let goal = goal {
            switch goal.frequency {
            case .Daily:
                startDate = cal.dateByAddingUnit(.Day, value: -7, toDate: endDate, options: opts)!
            case .Weekly:
                startDate = cal.dateByAddingUnit(.Day, value: -56, toDate: endDate, options: opts)!
            case .Monthly:
                startDate = cal.dateByAddingUnit(.Month, value: -12, toDate: endDate, options: opts)!
            case .Quarterly:
                startDate = cal.dateByAddingUnit(.Month, value: -24, toDate: endDate, options: opts)!
            case .Yearly:
                startDate = cal.dateByAddingUnit(.Year, value: -3, toDate: endDate, options: opts)!
            }
            
            // Limit the start to the oldest check-in.  Goals may have check-ins older than the created date
            if let last = goal.checkIns.last {
                if last.timeframe.startDate.timeIntervalSince1970 > startDate.timeIntervalSince1970 {
                    startDate = last.timeframe.startDate
                }
            }
        }
        
        
    }
}
