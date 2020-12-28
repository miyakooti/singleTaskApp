//
//  StringDateConverter.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/28.
//

import Foundation

class StringDateConverter{
    func stringToDate(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    func dateToString(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
