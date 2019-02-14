//
//  SelectGenreViewController.swift
//  Project 33
//
//  Created by Paul on 13.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
// Paul's note: experiments in progress. Beware of unused code.

import UIKit

class SelectGenreViewController: UITableViewController {
    // Paul's note: an enum would fit better here, probably. Especially for multilingual app.
    static let genres = ["Unknown", "Blues", "Classical", "Electronic", "Jazz", "Metal", "Pop", "Reggae", "RnB", "Rock", "Soul"]
    // We could go without this long line but we would have to generate localized strings manually then. Which is cumbersome.
    // Now Xcode will generate them for us fo sure.
    static let genresTranslations = [NSLocalizedString("Unknown", comment: ""), NSLocalizedString("Blues", comment: ""), NSLocalizedString("Classical", comment: ""), NSLocalizedString("Electronic", comment: ""), NSLocalizedString("Jazz", comment: ""), NSLocalizedString("Metal", comment: ""), NSLocalizedString("Pop", comment: ""), NSLocalizedString("Reggae", comment: ""), NSLocalizedString("RnB", comment: ""), NSLocalizedString("Rock", comment: ""), NSLocalizedString("Soul", comment: "")]
    
    // [Option 1] Dictionary [String : String] No, this aproach is a bad idea
    static var genresWithTranslations: [String : String] = dictionaryWithValues(forKeys: genres) as! [String : String] {
        didSet {
            for (index, key) in genres.enumerated() {
                genresWithTranslations[key] = genresTranslations[index]
            }
        }
    }
    
    // [Option 2] Dictionary [Enum : String]
    enum GenresOrig: String, CaseIterable {
        case unknown, blues, classical, electronic, jazz, metal, pop, reggae, rnB, rock, soul
    }

    static let genresLocalized = Dictionary(uniqueKeysWithValues: zip(Genres.allCases, Genres.allCases.map{ NSLocalizedString($0.rawValue, comment: "") }))
    
    static let genreByLocalizedName = Dictionary(uniqueKeysWithValues: zip(Genres.allCases.map{ NSLocalizedString($0.rawValue, comment: "") }, Genres.allCases))
    
    // [Option 3] Enum with self decoding func (rawValue version).
    enum Genres: String, CaseIterable {
        case unknown = "Unknown"
        case blues = "Blues"
        case classical = "Classical"
        
        func localizedName() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
        
        init?(index: Int) {
            guard Genres.allCases.indices.contains(index) else { return }
            self = Genres.allCases[index]
        }
    }
    
    // [Option 4] Custom struct with resolver as func. See implementation in extension.
    static let genresLocalizedStruct = EnumMap<Genres, String> { genre in  // Do not include type name in var name normally
        return NSLocalizedString(genre.rawValue, comment: "") // guarantneed to have value
        // or
        // return genresTranslations[genre.hashValue] // if they math
    }

    // [Option 5] Pure enum but it allows only single translation
    enum GenresForSingeForeignLanguage: String {
        case unknown = "Неизвестный"
        case blues = "Блюз"
        case classical = "Классика"
        // If only literals can serve as raw valuse
    }
    
    // [Option 5] Enum with self initialized (or mutated) associated value

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select genre"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Genre", style: .plain, target: self, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return SelectGenreViewController.genres.count //Paul's: type(of: self).genres.count will allow not to stick to class name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = type(of: self).Genres(index: indexPath.row) 
        cell.textLabel?.text = genre.localizedName()
        cell.tag = indexPath.row // ???: It used to be genre.hashValue
        #if DEBUG
        print("genre.hashValue = \(cell.tag) and indexPath.row = \(indexPath.row)")
        #endif
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let genre = Genres(index: cell.tag)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectGenreViewController {
    struct EnumMap<Enum: CaseIterable & Hashable, Value> {
        private let values: [Enum : Value]
        
        init(resolver: (Enum) -> Value) {
            var values = [Enum : Value]()
            
            for key in Enum.allCases {
                values[key] = resolver(key)
            }
            
            self.values = values
        }
        
        subscript(key: Enum) -> Value {
            // Here we have to force-unwrap, since there's no way
            // of telling the compiler that a value will always exist
            // for any given key. However, since it's kept private
            // it should be fine - and we can always add tests to
            // make sure things stay safe.
            return values[key]!
        }
    }
}
