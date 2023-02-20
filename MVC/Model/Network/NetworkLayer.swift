//
//  NetworkLayer.swift
//  homework4.4
//
//  Created by Ryskeldiev Islam on 4/1/23.
//

import UIKit

final class NetworkLayer {
    
    static let shared = NetworkLayer()
    private init() { }
    
    var baseURL = URL(string: "https://dummyjson.com/products")
    
    func decodeOrderTypeData(_ json: String) -> [OrderTypeModel] {
        var orderTypeModelArray = [OrderTypeModel]()
        let orderTypeData = Data(json.utf8)
        let jsonDecoder = JSONDecoder()
        do { let orderTypeModelData = try jsonDecoder.decode([OrderTypeModel].self, from: orderTypeData)
            orderTypeModelArray = orderTypeModelData
        } catch {
            print(error.localizedDescription)
        }
        return orderTypeModelArray
    }
    
    // GET ASYNC 
    func fetchProductsData() async throws -> MainProductModel {
        guard let url = baseURL else { return MainProductModel(products: []) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MainProductModel.self, from: data)
    }
    
    func findProductsData(text: String) async throws -> MainProductModel {
        guard let url = baseURL else { return MainProductModel(products: []) }
        let urlQueryItem = URLQueryItem(name: "q", value: text)
        let request = URLRequest(url: url.appendingPathComponent("search").appending(queryItems: [urlQueryItem]))
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MainProductModel.self, from: data)
    }
    
    func postProductsData(model: ProductModel, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = baseURL else { return }
        
        var encodedProductModel: Data?
        encodedProductModel = initializeData(product: encodedProductModel)
        guard encodedProductModel != nil else { return }
        
        var request = URLRequest(url: url.appendingPathComponent("add"))
        request.httpMethod = "POST"
        request.httpBody = encodedProductModel
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            print("RESPONSE:\(String(describing: response))")
            guard let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
    
    func putProductsData(
        id:Int,
        model: ProductModel,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = baseURL else { return }
        
        var encodedProductModel: Data?
        encodedProductModel = initializeData(product: encodedProductModel)
        guard encodedProductModel != nil else { return }
        
        var request = URLRequest(url: url.appendingPathComponent("\(id)"))
        request.httpMethod = "PUT"
        request.httpBody = encodedProductModel
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            print("RESPONSE:\(String(describing: response))")
            guard let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
    
    func deleteProductsData(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = baseURL else { return }
        
        var request = URLRequest(url: url.appendingPathComponent("\(id)"))
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            print("RESPONSE:\(String(describing: response))")
        }
        task.resume()
    }
    
    func decodeData<T: Decodable>(data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    func encodeData<T: Encodable>(product: T, completion: @escaping (Result<Data, Error>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(product)
            completion(.success(encodedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func initializeData<T: Encodable>(product: T) -> Data? {
        var encodedData: Data?
        encodeData(product: product) { result in
            switch result {
            case .success(let model):
                encodedData = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return encodedData
    }
    
}

