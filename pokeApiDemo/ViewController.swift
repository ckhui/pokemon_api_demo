//
//  ViewController.swift
//  pokeApiDemo
//
//  Created by NEXTAcademy on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var pokemon = [[String : Any]]()
    
    @IBOutlet weak var pokemonTableView: UITableView! {
        didSet {
            pokemonTableView.dataSource = self
            pokemonTableView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchData(){
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/")
            else {
                print("Error : cannot creat URL")
                return
        }
        
        let session = URLSession.shared
        
        //make request
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil else
            {
                print ("Error : \(error)")
                return
            }
            
            guard let responseData = data else
            {
                print ("Error : did not receive data")
                return
            }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any]
                    else {
                        print ("error converting to JSON")
                        return
                }
                
                //successfully getting data in JSON format
                print(jsonResponse)
                
                if let pokemons = jsonResponse["results"] as? [Any] {
                    for tempPokemon in pokemons {
                        
                        if let pokeDetails = tempPokemon as? [String : Any]{
                            self.pokemon.append(pokeDetails)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.pokemonTableView.reloadData()
                }
                
                
            }catch {
                print ("error converting to JSON")
                return
            }
        })
        
        task.resume()
        
    }
    
    
    func getPokemonDetails(url : String){
        guard let url = URL(string: url)
            else {
                print("Error : cannot creat URL")
                return
        }
        
        let session = URLSession.shared
        
        //make request
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil else
            {
                print ("Error : \(error)")
                return
            }
            
            guard let responseData = data else
            {
                print ("Error : did not receive data")
                return
            }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any]
                    else {
                        print ("error converting to JSON")
                        return
                }
                
                //successfully getting data in JSON format
                //print(jsonResponse)
                
                guard let sprites = jsonResponse["sprites"] as? [String : Any],
                    let imgUrl = sprites["front_default"] as? String
                    else {
                        print("Error getting image url")
                        return
                }
                
                
                DispatchQueue.main.async {
                    self.title = jsonResponse["name"] as? String
                    self.assignImage(url : imgUrl)
                }
                
                
            }catch {
                print ("error converting to JSON")
                return
            }
        })
        
        task.resume()
        
    }
    
    
    func assignImage(url imgUrl : String){
        /*
        if let url = URL(string: imgUrl){
            do {
            let imgData = try Data(contentsOf: url)
            imageView.image = UIImage(data: imgData)
            }
            catch {
                print("Error loading image from url")
            }
        }
        */
        
        guard let url = URL(string: imgUrl)
            else{ return }
        
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.imageView.image = UIImage(data: data!)
            })
            
        }).resume()
        
        
    }
    
}


extension ViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell")
            else { return UITableViewCell() }
        
        cell.textLabel?.text = pokemon[indexPath.row]["name"] as? String
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = pokemon[indexPath.row]["url"] as? String
            else {
                return
        }
        getPokemonDetails(url: url)
        
    }
    
}
