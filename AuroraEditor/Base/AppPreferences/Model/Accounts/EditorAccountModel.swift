//
//  EditorAccountModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A model to handle the editor account
class EditorAccountModel: ObservableObject {
    /// The callback for a successful login
    typealias LoginSuccessfulCallback = () -> Void

    /// The preferences model
    private var prefs: AppPreferencesModel = .shared

    /// The keychain
    private let keychain = AuroraEditorKeychain()

    @Published
    /// A boolean to dismiss the dialog
    var dismissDialog: Bool

    /// Initializes a new editor account model
    init(dismissDialog: Bool) {
        self.dismissDialog = dismissDialog
    }

    /// Logs in to your Aurora Editor account
    /// 
    /// - Parameter email: email address
    /// - Parameter password: password
    /// - Parameter successCallback: the callback for a successful login
    func loginAuroraEditor(
        email: String,
        password: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]

        AuroraNetworking().request(
            baseURL: Constants.auroraEditorBaseURL,
            path: Constants.login,
            useAuthType: .none,
            method: .POST,
            parameters: parameters,
        completionHandler: { completion in
            switch completion {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let login = try decoder.decode(AELogin.self, from: data)

                    DispatchQueue.main.async {
                        self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                            SourceControlAccounts(id: "aurora-" + login.user.id,
                                                  gitProvider: "Aurora Editor",
                                                  gitProviderLink: "https://auroraeditor.com",
                                                  gitProviderDescription: "Official Aurora Editor Account",
                                                  gitAccountName: "\(login.user.firstName) \(login.user.lastName)",
                                                  gitAccountEmail: login.user.email,
                                                  gitAccountUsername: "",
                                                  gitAccountImage: login.user.profileImage,
                                                  gitCloningProtocol: false,
                                                  gitSSHKey: "",
                                                  isTokenValid: true)
                        )
                        self.dismissDialog.toggle()
                        successCallback()
                    }
                    self.keychain.set(login.accessToken, forKey: "auroraeditor_access_\(email)")
                    self.keychain.set(login.refreshToken, forKey: "auroraeditor_refresh_\(email)")
                } catch {

                }
            case .failure(let failure):
                Log.fault("\(failure)")
            }
        })
    }

    /// Logs in to your Gitlab account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter accountName: the name of the account
    /// - Parameter successCallback: the callback for a successful login
    func loginGitlab(gitAccountName: String,
                     accountToken: String,
                     accountName: String,
                     successCallback: @escaping LoginSuccessfulCallback) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitlabTokenConfiguration(accountToken)
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(
                            id: "gitlab-" + gitAccountName.lowercased(),
                            gitProvider: "Gitlab",
                            gitProviderLink: "https://gitlab.com",
                            gitProviderDescription: "Gitlab",
                            gitAccountName: gitAccountName,
                            gitAccountEmail: "user.email",
                            gitAccountUsername: "user.username",
                            gitAccountImage: "user.avatarURL?.absoluteString!",
                            gitCloningProtocol: true,
                            gitSSHKey: "",
                            isTokenValid: true
                        )
                    )
                    self.keychain.set(accountToken, forKey: "gitlab_\(accountName)")
                    self.dismissDialog.toggle()
                    successCallback()
                }
            case .failure(let error):
                Log.fault("\(error)")
            }
        }
    }

    /// Logs in to your self hosted Gitlab account
    ///
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter enterpriseLink: the link to the enterprise
    /// - Parameter successCallback: the callback for a successful login
    func loginGitlabSelfHosted(
        gitAccountName: String,
        accountToken: String,
        enterpriseLink: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitlabTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: "gitlab-sh-" + gitAccountName.lowercased(),
                                              gitProvider: "Gitlab",
                                              gitProviderLink: enterpriseLink,
                                              gitProviderDescription: "Gitlab",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: "user.email!",
                                              gitAccountUsername: "user.username",
                                              gitAccountImage: "user.avatarURL?.relativeString!",
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    self.keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                    self.dismissDialog.toggle()
                    successCallback()
                }
            case .failure(let error):
                Log.fault("\(error)")
            }
        }
    }

    /// Logs in to your Github account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter successCallback: the callback for a successful login
    func loginGithub(
        gitAccountName: String,
        accountToken: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GithubTokenConfiguration(accountToken)
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    DispatchQueue.main.async {
                        self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                            SourceControlAccounts(id: "github-" + gitAccountName.lowercased(),
                                                  gitProvider: "GitHub",
                                                  gitProviderLink: "https://github.com",
                                                  gitProviderDescription: "GitHub",
                                                  gitAccountName: gitAccountName,
                                                  gitAccountEmail: user.email ?? "Not Found",
                                                  gitAccountUsername: user.login!,
                                                  gitAccountImage: user.avatarURL!,
                                                  gitCloningProtocol: true,
                                                  gitSSHKey: "",
                                                  isTokenValid: true))
                        self.keychain.set(accountToken, forKey: "github_\(user.login!)")
                    }
                    self.dismissDialog.toggle()
                    successCallback()
                }
            case .failure(let error):
                Log.fault("\(error)")
            }
        }
    }

    /// Logs in to your self hosted Github account
    /// 
    /// - Parameter gitAccountName: the name of the git account
    /// - Parameter accountToken: the token of the account
    /// - Parameter accountName: the name of the account
    /// - Parameter enterpriseLink: the link to the enterprise
    /// - Parameter successCallback: the callback for a successful login
    func loginGithubEnterprise(
        gitAccountName: String,
        accountToken: String,
        accountName: String,
        enterpriseLink: String,
        successCallback: @escaping LoginSuccessfulCallback
    ) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GithubTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: "github-ent-" + gitAccountName.lowercased(),
                                              gitProvider: "GitHub",
                                              gitProviderLink: enterpriseLink,
                                              gitProviderDescription: "GitHub",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: user.email!,
                                              gitAccountUsername: user.login!,
                                              gitAccountImage: user.avatarURL!,
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    self.keychain.set(accountToken, forKey: "github_\(accountName)_enterprise")
                    self.dismissDialog.toggle()
                    successCallback()
                }
            case .failure(let error):
                Log.fault("\(error)")
            }
        }
    }
}
