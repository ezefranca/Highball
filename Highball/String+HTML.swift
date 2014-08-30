//
//  String+HTML.swift
//  Highball
//
//  Created by Ian Ynda-Hummel on 8/28/14.
//  Copyright (c) 2014 ianynda. All rights reserved.
//

import Foundation

public extension NSString {

    func htmlStringWithTumblrStyle(width: CGFloat) -> (NSString) {
        let style = "body{max-width:\(width)px;}blockquote{border-left-color:rgba(0, 0, 0, 0.117647);border-left-style:solid;border-left-width:4px;box-sizing:border-box;color:rgb(68,68,68);display:block;font-size:14px;font-style:normal;font-weight:normal;line-height:19.6px;list-style-type:none;margin-bottom:0px;margin-top:0px;margin-left:10px;margin-right:10px;outline-color:rgb(68,68,68);outline-style:none;outline-width:0px;padding-left:15px;text-align:left;}a{box-sizing: border-box;color: rgb(68, 68, 68);cursor: auto;display: inline;font-family: 'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;font-size: 14px;font-style: normal;font-variant: normal;font-weight: normal;height: auto;line-height: 19.600000381469727px;list-style-type: none;outline-color: rgb(68, 68, 68);outline-style: none;outline-width: 0px;text-align: left;text-decoration: underline solid rgb(68, 68, 68);width: auto;}p{box-sizing: border-box;color: rgb(68, 68, 68);display: block;font-family: 'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;font-size: 14px;font-style: normal;font-variant: normal;font-weight: normal;line-height: 19.600000381469727px;list-style-type: none;margin-bottom: 10px;margin-left: 0px;margin-right: 0px;margin-top: 0px;}img{max-width:100%;height:auto!important;display: block;box-sizing: border-box;}"
        return "<html><head><style>\(style)</style></head><body><div id='main'>\(self)</div></body></html>"
    }

}