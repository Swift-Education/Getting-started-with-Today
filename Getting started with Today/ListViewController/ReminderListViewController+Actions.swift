//
//  ReminderListViewController+Actions.swift
//  Getting started with Today
//
//  Created by 강동영 on 10/11/24.
//

import UIKit

extension ReminderListViewController {
    //@objc 속성은 해당 메서드를 Objective-C 코드에서 사용할 수 있게 합니다.
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(with: id)
    }
}
