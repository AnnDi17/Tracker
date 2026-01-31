//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Анна Лапухина on 31.01.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLightTheme() throws {
        let vc = TrackersViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkTheme() throws {
        let vc = TrackersViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
}
