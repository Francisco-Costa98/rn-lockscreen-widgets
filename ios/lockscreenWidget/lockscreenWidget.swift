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
}

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> StatusEntry {
    StatusEntry(date: Date(), fakeStatus: "Hello from 1", configuration: ConfigurationIntent())
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (StatusEntry) -> ()) {
    let entry = StatusEntry(date: Date(), fakeStatus: "Hello from 2", configuration: configuration)
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
          let entry = StatusEntry(date: nextRefresh, fakeStatus: parsedData.text, configuration: configuration)
          let timeline = Timeline(entries: [entry], policy: .atEnd)
          completion(timeline)
        } else {
          print("Could not parse data")
        }
      } else {
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 3, to: entryDate)!
        let entry = StatusEntry(date: nextRefresh, fakeStatus: "No data set", configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
      }
    }
  }
}

struct StatusEntry: TimelineEntry {
    let date: Date
    let fakeStatus: String
    let configuration: ConfigurationIntent
}

struct lockscreenWidgetEntryView : View {
    var entry: Provider.Entry
  
    @ViewBuilder
  var body: some View {
    VStack(alignment: .leading) {
      Text(entry.date, style: .time )
      Spacer()

      Text(entry.fakeStatus )
    }
    .padding(7.0)
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
        lockscreenWidgetEntryView(entry: StatusEntry(date: Date(), fakeStatus: "Mo was hefsdfdsfdsfdsfre", configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall)
          
        )
        .border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/3/*@END_MENU_TOKEN@*/)
        .cornerRadius(/*@START_MENU_TOKEN@*/5.0/*@END_MENU_TOKEN@*/)
    }
}
