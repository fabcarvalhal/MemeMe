//
//  MemeStorage.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class MemeStorage {
    
    static let instance = MemeStorage()
    
    private var memeList = [Meme]()
    
    private init() {}
    
    func save(_ meme: Meme) {
        memeList.append(meme)
    }
    
    func getList() -> [Meme] {
        return memeList
    }
    
    func replace(_ item: Meme, with newItem: Meme) {
        guard let existingItemIndex = memeList.firstIndex(where: { $0 == item }) else { return }
        remove(at: existingItemIndex)
        memeList.insert(newItem, at: existingItemIndex)
    }
    
    func remove(at index: Int) {
        guard listHasIndex(index) else { return }
        memeList.remove(at: index)
    }
    
    private func listHasIndex(_ index: Int) -> Bool {
        return memeList.indices.contains(index)
    }
}
