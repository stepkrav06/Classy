//
//  ClassyWidgetsBundle.swift
//  ClassyWidgets
//
//  Created by Степан Кравцов on 18.04.2023.
//

import WidgetKit
import SwiftUI

@main
struct ClassyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NextLessonWidget()
        ScheduleDayWidget()
    }
}
