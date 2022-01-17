[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

# NBP currency app 🏦

## DEMO
This project is a currency app made with NBP's API. </br>
Allows user to get all nessesary ifnormation about currencies. </br>
<img src="readme_files/NBP_DEMO.gif" alt="demo_gif" width="386"/> </br>

## PROJECT REQUAIRMENTS 📄
Write a simple system support application from iOS 10, which displays the exchange rates downloaded from the National Bank of Poland's API (http://api.nbp.pl). </br>

1. Main screen:
  a. Displays the currency rates from the endpoint http://api.nbp.pl/api/exchangerates/tables/{table}/
  b. You want to change the table you are displaying, the table parameter from the endpoint,
  c. Cells from UIColleticon View or UITableView should be created other than system cells,
  d. Cells should include information on:
    i.. Date entered
    ii. The name of the currency
    iii. The currency code
    iv. The average value of the course
  e. Pressing a cell with a currency moves to (2. Currency screen),
  f. The user has the ability to refresh the data manually,
  g. The screen should show the data loading CLIP.
2. Screen
  a. The title should include the currency name,
  b. The screen displays the average exchange rates for the selected by the date user from the endpoints http://api.nbp.pl/api/exchangerates/rates/{table}/{code}/{startDate}/{endDate}/
  c. The user must be able to select dates on this screen.
  d. The user has the ability to refresh the data manually,
  e. The screen should show the data loading CLIP.

## REQUAIRMENTS 📄
- iOS 10.0+
- Xcode 13.1

## Installation
This app requaires [Charts 3.6.0](https://cocoapods.org/pods/Charts). It's a module that supports adding charts to iOS project. It's on Apache-2.0 license.
#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `Charts` by adding it to your `Podfile`:

```ruby
pod 'Charts'
```

Then use command `pod install` inside terminal to install selected pod:

```bash
pod install
```



