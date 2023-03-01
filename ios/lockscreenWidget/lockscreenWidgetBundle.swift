//
//  lockscreenWidgetBundle.swift
//  lockscreenWidget
//
//  Created by Francisco Costa on 19/01/2023.
//

import WidgetKit
import SwiftUI

@main
struct lockscreenWidgetBundle: WidgetBundle {
    var body: some Widget {
        lockscreenWidget()
        lockscreenWidgetLiveActivity()
    }
}
