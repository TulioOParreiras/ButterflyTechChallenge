//
//  MoviesListViewController+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import UIKit

@testable import ButterflyChallenge

extension MoviesListViewController {
    func simulateUserInitiatedMoviesListReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateMovieCellVisible(at index: Int) -> MovieViewCell? {
        return cell(at: index) as? MovieViewCell
    }
    
    @discardableResult
    func simulateMovieCellNotVisible(at row: Int) -> MovieViewCell? {
        let view = simulateMovieCellVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: movisListSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateMovieCellNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: movisListSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateMovieCellNotNearVisible(at row: Int) {
        simulateMovieCellNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: movisListSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }

    func simulateCellSelection(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: movisListSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl!.isRefreshing == true
    }
    
    func simulateSearchForText(_ text: String) {
        searchBar.searchTextField.text = text
        searchBar.searchTextField.simulate(event: .editingChanged)
    }
    
    func numberOfRenderedCells() -> Int {
        return tableView.numberOfRows(inSection: movisListSection)
    }
    
    func cell(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedCells() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: movisListSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var movisListSection: Int {
        return 0
    }
    
    var numberOfShimmeringCells: Int { Constants.shimmeringCellsCount }
    
    var errorMessage: String? {
        errorView?.message
    }
    
}
