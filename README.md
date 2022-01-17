# NBP currency app 🏦

## DEMO
This project is a currency app made with NBP's API. </br>
Allows user to get all nessesary ifnormation about currencies. </br>
<img src="readme_files/NBP_DEMO.gif" alt="demo_gif" width="386"/> </br>

## PROJECT REQUAIRMENTS 📄
Write a simple system support application from iOS 10, which displays the exchange rates downloaded from the National Bank of Poland's API (http://api.nbp.pl). </br>

1. Main screen:
  - Displays the currency rates from the endpoint http://api.nbp.pl/api/exchangerates/tables/{table}/
  - You want to change the table you are displaying, the table parameter from the endpoint,
  - Cells from UIColleticon View or UITableView should be created other than system cells,
  - Cells should include information on:
    - Date entered
    - The name of the currency
    - The currency code
    - The average value of the course
  - Pressing a cell with a currency moves to (2. Currency screen),
  - The user has the ability to refresh the data manually,
  - The screen should show the data loading CLIP.
2. Detail Screen (range rates)
  - The title should include the currency name,
  - The screen displays the average exchange rates for the selected by the date user from the endpoints http://api.nbp.pl/api/exchangerates/rates/{table}/{code}/{startDate}/{endDate}/
  - The user must be able to select dates on this screen.
  - The user has the ability to refresh the data manually,
  - The screen should show the data loading CLIP.

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



