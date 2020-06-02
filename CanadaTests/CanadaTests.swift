//
//  CanadaTests.swift
//  CanadaTests
//
//  Created by Vignesh on 15/05/20.
//  Copyright © 2020 Vignesh. All rights reserved.
//

import XCTest
@testable import Canada

class CanadaTests: XCTestCase {
    
    var viewControllerUnderTest: CanadaViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.viewControllerUnderTest = CanadaViewController()
        self.viewControllerUnderTest.loadView()
        self.viewControllerUnderTest.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRequestForDataMethod() {
        XCTAssertNotNil(self.viewControllerUnderTest!.requestForData, "requestForData method not called")
    }
    
    func testShowIndicatorMethod() {
        XCTAssertNotNil(self.viewControllerUnderTest!.showIndicator, "showIndicator method not called")
    }
    
    func testHideIndicatorMethod() {
        XCTAssertNotNil(self.viewControllerUnderTest!.hideIndicator, "hideIndicator method not called")
    }
    
    func testThatViewConformsToUITableViewDelegate() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDelegate.self))
    }
    
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.numberOfSections(in:))))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:cellForRowAt:))))
    }
    
    func testAPIServicaCall() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download some data")
        
        // Create a URL for a web page to be downloaded.
        // Give some wrong URL to fail in the test
        let url = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")!
        
        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            // Make sure we downloaded some data.
            XCTAssertNotNil(data, "No data was downloaded.")
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Start the download task.
        dataTask.resume()
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Verify all the cosnstant values
    func testAllConstantValues() {
        let requestUrl = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
        let cellId = "canadaTableViewCellId"
        let defaultImageName = "FileMissing.png"
        let noInternetAlert = "Internet Connection not Available! Try After sometime"
        let indicatorLableText = "Indicator"
        let indicatorDetailText =  "fetching details"
        
        XCTAssertEqual(requestUrl, Constants.RequestUrl)
        XCTAssertEqual(cellId, Constants.CellId)
        XCTAssertEqual(defaultImageName, Constants.DefaultImageName)
        XCTAssertEqual(noInternetAlert, Constants.NoInternetAlert)
        XCTAssertEqual(indicatorLableText, Constants.IndicatorLableText)
        XCTAssertEqual(indicatorDetailText, Constants.IndicatorDetailText)
    }
    
    // We are forcefully hiding the status bar
    func testStatusBarHeight() {
        XCTAssertEqual(viewControllerUnderTest.prefersStatusBarHidden, false)
    }
    
    // Turn off the internet connection to test this case
    func testInternetAvailability() {
        XCTAssertEqual(Reachability.isConnectedToNetwork(), true)
    }
    
    
    func testAllPropertiesMatchIsTrue() {
        let one = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description")
        let two = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description")
        XCTAssertEqual(one, two)
    }
    
    func testFactNameIsDifferent() {
        let one = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description")
        let two = CanadaItem(factName: "Flag", factImage: "imageURL", factDesc: "description")
        XCTAssertNotEqual(one, two)
    }
    
    func testImageURLIsDifferent() {
        let one = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description")
        let two = CanadaItem(factName: "Beavers", factImage: "imageURL2", factDesc: "description")
        XCTAssertNotEqual(one, two)
    }
    
    func testDescriptionIsDifferent() {
        let one = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description")
        let two = CanadaItem(factName: "Beavers", factImage: "imageURL", factDesc: "description2")
        XCTAssertNotEqual(one, two)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
