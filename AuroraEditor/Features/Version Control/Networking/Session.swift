//
//  Session.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

// This file should be strictly just be used for Accounts since it's not
// built for any other networking except those of git accounts

import Foundation

@available(*,
            deprecated,
            renamed: "VersionControl",
            message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// GIT URLSession
public protocol GitURLSession {

    /// Data task
    /// 
    /// - Parameters:
    ///   - request: request
    ///   - completionHandler: completionHandler
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func dataTaskGit(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol

    /// Upload task
    /// 
    /// - Parameters:
    ///   - request: request
    ///   - bodyData: body data
    ///   - completionHandler: completionHandler
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol

#if !canImport(FoundationNetworking)
    /// Data task
    /// 
    /// - Parameters:
    ///   - request: request
    ///   - delegate: delegate
    /// 
    /// - Returns: (Data, URLResponse)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func data(for request: URLRequest,
              delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)

    /// Upload task
    /// 
    /// - Parameters:
    ///   - request: request
    ///   - bodyData: body data
    ///   - delegate: delegate
    /// 
    /// - Returns: (Data, URLResponse)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func upload(for request: URLRequest,
                from bodyData: Data,
                delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
#endif
}

/// URLSessionDataTaskProtocol
public protocol URLSessionDataTaskProtocol {
    /// Resume
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension URLSession: GitURLSession {
    /// Data task for git
    /// 
    /// - Parameter request: request
    /// - Parameter completionHandler: completionHandler
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    public func dataTaskGit(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol {
            (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
        }

    /// Upload task for git
    /// 
    /// - Parameter request: request
    /// - Parameter bodyData: body data
    /// - Parameter completionHandler: completionHandler
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    public func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
            uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
        }
}
