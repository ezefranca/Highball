//
//  AccountsService.swift
//  Highball
//
//  Created by Ian Ynda-Hummel on 12/16/14.
//  Copyright (c) 2014 ianynda. All rights reserved.
//

import UIKit
import SwiftyJSON
import TMTumblrSDK
import OAuthSwift

struct Account {
    let blog: Blog
    let token: String
    let tokenSecret: String

    init(blog: Blog, token: String, tokenSecret: String) {
        self.blog = blog
        self.token = token
        self.tokenSecret = tokenSecret
    }
}

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.token == rhs.token
}

struct AccountsService {
    private static let accountsDefaultsKey = "AccountsViewControllerAccountsDefaultsKey"
    private static let lastAccountDefaultsKey = "lastAccountDefaultsKey"

    private static let accountBlogDataKey = "accountBlogDataKey"
    private static let accountOAuthTokenKey = "accountOAuthToken"
    private static let accountOAuthTokenSecretKey = "accountOAuthTokenSecret"

    static var account: Account!

    static func start(fromViewController viewController: UIViewController, completion: () -> ()) {
        if let lastAccount = self.lastAccount() {
            self.loginToAccount(lastAccount, completion: completion)
            return
        }

        let accounts = self.accounts()
        if accounts.count > 0 {
            self.loginToAccount(accounts.first!, completion: completion)
        } else {
            self.authenticateNewAccount(fromViewController: viewController) { (account) -> () in
                if let account = account {
                    self.loginToAccount(account, completion: completion)
                } else {
                    self.start(fromViewController: viewController, completion: completion)
                }
            }
        }
    }

    static func accounts() -> Array<Account> {
        return self.accountDictionaries().map { (accountDictionary) -> Account in
            let blogData = accountDictionary[self.accountBlogDataKey]! as! NSData
            let blog = NSKeyedUnarchiver.unarchiveObjectWithData(blogData) as! Blog
            return Account(
                blog: blog,
                token: accountDictionary[self.accountOAuthTokenKey]! as! String,
                tokenSecret: accountDictionary[self.accountOAuthTokenSecretKey]! as! String
            )
        }
    }

    static func lastAccount() -> Account? {
        if let accountDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(self.lastAccountDefaultsKey) {
            let blogData = accountDictionary[self.accountBlogDataKey]! as! NSData
            let blog = NSKeyedUnarchiver.unarchiveObjectWithData(blogData) as! Blog
            return Account(
                blog: blog,
                token: accountDictionary[self.accountOAuthTokenKey]! as! String,
                tokenSecret: accountDictionary[self.accountOAuthTokenSecretKey]! as! String
            )
        }
        return nil
    }

    static func loginToAccount(account: Account, completion: () -> ()) {
        self.account = account
        let accountDictionary = [
            self.accountBlogDataKey : NSKeyedArchiver.archivedDataWithRootObject(account.blog),
            self.accountOAuthTokenKey : account.token,
            self.accountOAuthTokenSecretKey : account.tokenSecret
        ]

        TMAPIClient.sharedInstance().OAuthToken = account.token
        TMAPIClient.sharedInstance().OAuthTokenSecret = account.tokenSecret

        NSUserDefaults.standardUserDefaults().setObject(accountDictionary, forKey: self.lastAccountDefaultsKey)

        dispatch_async(dispatch_get_main_queue(), completion)
    }

    static func authenticateNewAccount(fromViewController viewController: UIViewController, completion: (account: Account?) -> ()) {
        let oauth = OAuth1Swift(
            consumerKey: TMAPIClient.sharedInstance().OAuthConsumerKey,
            consumerSecret: TMAPIClient.sharedInstance().OAuthConsumerSecret,
            requestTokenUrl: "https://www.tumblr.com/oauth/request_token",
            authorizeUrl: "https://www.tumblr.com/oauth/authorize",
            accessTokenUrl: "https://www.tumblr.com/oauth/access_token"
        )
        let currentAccount: Account? = self.account

        self.account = nil

        TMAPIClient.sharedInstance().OAuthToken = nil
        TMAPIClient.sharedInstance().OAuthTokenSecret = nil

        oauth.authorize_url_handler = SafariURLHandler(viewController: viewController)

        oauth.authorizeWithCallbackURL(
            NSURL(string: "highball://oauth-callback")!,
            success: { (credential, response, parameters) in
                TMAPIClient.sharedInstance().OAuthToken = credential.oauth_token
                TMAPIClient.sharedInstance().OAuthTokenSecret = credential.oauth_token_secret

                TMAPIClient.sharedInstance().userInfo { response, error in
                    if let _ = error {
                        completion(account: nil)
                        return
                    }

                    let json = JSON(response)
                    let blogs = json["user"]["blogs"].array!.map({ Blog(json: $0) })
                    let primaryBlog = blogs.filter({ $0.primary }).first
                    let account = Account(
                        blog: primaryBlog!,
                        token: TMAPIClient.sharedInstance().OAuthToken,
                        tokenSecret: TMAPIClient.sharedInstance().OAuthTokenSecret
                    )
                    var accountDictionaries = self.accountDictionaries()
                    let accountDictionary = [
                        self.accountBlogDataKey : NSKeyedArchiver.archivedDataWithRootObject(account.blog),
                        self.accountOAuthTokenKey : account.token,
                        self.accountOAuthTokenSecretKey : account.tokenSecret
                    ]

                    accountDictionaries.append(accountDictionary)

                    NSUserDefaults.standardUserDefaults().setObject(accountDictionaries, forKey: self.accountsDefaultsKey)

                    self.account = currentAccount

                    TMAPIClient.sharedInstance().OAuthToken = currentAccount?.token
                    TMAPIClient.sharedInstance().OAuthTokenSecret = currentAccount?.tokenSecret

                    completion(account: account)
                }
            },
            failure: { (error) in
                print(error)
            }
        )
    }

    static func deleteAccount(account: Account, fromViewController viewController: UIViewController, completion: () -> ()) {
        let accountDictionaries = self.accounts().filter({ existingAccount in
            return !(existingAccount == account)
        }).map({ existingAccount -> Dictionary<String, AnyObject> in
            return [
                self.accountBlogDataKey : NSKeyedArchiver.archivedDataWithRootObject(existingAccount.blog),
                self.accountOAuthTokenKey : existingAccount.token,
                self.accountOAuthTokenSecretKey : existingAccount.tokenSecret
            ]
        })

        NSUserDefaults.standardUserDefaults().setObject(accountDictionaries, forKey: self.accountsDefaultsKey)

        if self.account == account {
            self.account = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(self.lastAccountDefaultsKey)
            self.start(fromViewController: viewController, completion: completion)
        } else {
            dispatch_async(dispatch_get_main_queue(), completion)
        }
    }

    private static func accountDictionaries() -> Array<Dictionary<String, AnyObject>> {
        if let accountDictionaries = NSUserDefaults.standardUserDefaults().arrayForKey(self.accountsDefaultsKey) as? Array<Dictionary<String, AnyObject>> {
            return accountDictionaries
        } else {
            return []
        }
    }
}
