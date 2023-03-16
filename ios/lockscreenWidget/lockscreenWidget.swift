//
//  lockscreenWidget.swift
//  lockscreenWidget
//
//  Created by Francisco Costa on 19/01/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct WidgetData: Decodable {
   var text: String
   var minGaugeVal: Double
   var maxGaugeVal: Double
   var currentGaugeVal: Double
   var icon: String?
}

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> StatusEntry {
    StatusEntry(date: Date(), text: "Text goes here", configuration: ConfigurationIntent(), minGaugeVal: 0, maxGaugeVal: 100, currentGaugeVal: 50, icon: "waveform")
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (StatusEntry) -> ()) {
    let entry = StatusEntry(date: Date(), text: "Text goes here", configuration: configuration, minGaugeVal: 0, maxGaugeVal: 100, currentGaugeVal: 50, icon: "waveform")
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    print("Getting timeline")
    let userDefaults = UserDefaults.init(suiteName: "group.RNLockscreenWidget")
    if userDefaults != nil {
      let entryDate = Date()
      if let savedData = userDefaults!.value(forKey: "widgetKey") as? String {
        let decoder = JSONDecoder()
        let data = savedData.data(using: .utf8)
        if let parsedData = try? decoder.decode(WidgetData.self, from: data!) {
          print("Data parsed")
          let nextRefresh = Calendar.current.date(byAdding: .minute, value: 3, to: entryDate)!
          let entry = StatusEntry(date: nextRefresh, text: parsedData.text, configuration: configuration, minGaugeVal: parsedData.minGaugeVal, maxGaugeVal: parsedData.maxGaugeVal, currentGaugeVal: parsedData.currentGaugeVal, icon: parsedData.icon ?? "waveform")
          let timeline = Timeline(entries: [entry], policy: .atEnd)
          completion(timeline)
        } else {
          print("Could not parse data")
        }
      } else {
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 3, to: entryDate)!
        let entry = StatusEntry(date: nextRefresh, text: "No data set", configuration: configuration, minGaugeVal: 0, maxGaugeVal: 100, currentGaugeVal: 50, icon: "waveform")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
      }
    }
  }
}

struct StatusEntry: TimelineEntry {
  var date: Date
  
  let text: String
  let configuration: ConfigurationIntent
  let minGaugeVal: Double
  let maxGaugeVal: Double
  let currentGaugeVal: Double
  let icon: String
}

struct circularGaugeWidgetView: View {
  var currVal : Double
  var minVal :Double
  var maxVal : Double
  var icon: String
  @ViewBuilder
  var body: some View {
      Gauge(value: currVal, in: minVal...maxVal) {
      } currentValueLabel: {
        Image(systemName: icon).font(.caption)
      } minimumValueLabel: {
        Text("\(Int(minVal))")
          .foregroundColor(Color.green)
      } maximumValueLabel: {
        Text("\(Int(maxVal))")
          .foregroundColor(Color.red)
      }
      .gaugeStyle( .accessoryCircular)}
}

struct rectangularGaugeWidgetView: View {
  var currVal : Double
  var minVal :Double
  var maxVal : Double
  var icon: String
  var text: String
  
  @ViewBuilder
  var body: some View {
  
        Gauge(value: currVal, in: minVal...maxVal) {
          Text(text)
            .scaledToFill()
            .minimumScaleFactor(0.5)
        } currentValueLabel: {
          HStack{
            Image(systemName: icon)
            Text("\(Int(currVal))")
          }.font(.caption)
        }minimumValueLabel: {
          Text("\(Int(minVal))")
            .foregroundColor(Color.green)
        } maximumValueLabel: {
          Text("\(Int(maxVal))")
            .foregroundColor(Color.red)
        }
        .gaugeStyle(.accessoryLinearCapacity)
        .padding()
      }}

struct lockscreenWidgetEntryView : View {
  var entry: Provider.Entry
  
  // Obtain the widget family value
  @Environment(\.widgetFamily)
  var family
  
  @ViewBuilder
  var body: some View {
    switch family {
    case .accessoryCircular :
      circularGaugeWidgetView(currVal: entry.currentGaugeVal, minVal: entry.minGaugeVal, maxVal: entry.maxGaugeVal, icon: entry.icon);
    case .accessoryRectangular:
      rectangularGaugeWidgetView(currVal: entry.currentGaugeVal, minVal: entry.minGaugeVal, maxVal: entry.maxGaugeVal, icon: entry.icon, text: entry.text);
    default:
        Text("Not supported for this view")
    }
  }
}

struct lockscreenWidget: Widget {
    let kind: String = "lockscreenWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            lockscreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([WidgetFamily.accessoryRectangular, WidgetFamily.accessoryCircular])
    
    }
}

struct lockscreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        lockscreenWidgetEntryView(entry: StatusEntry(date: Date(), text: "Mo was here", configuration: ConfigurationIntent(), minGaugeVal: 0, maxGaugeVal: 100, currentGaugeVal: 50, icon: "waveform"))
        .previewContext(WidgetPreviewContext(family: .systemSmall)
          
        )
        .border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/3/*@END_MENU_TOKEN@*/)
        .cornerRadius(/*@START_MENU_TOKEN@*/5.0/*@END_MENU_TOKEN@*/)
    }
}
