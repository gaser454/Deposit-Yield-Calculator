// deposit_calculator.swift
import Foundation

func getFloat(prompt: String) -> Double {
    while true {
        print(prompt, terminator: "")
        if let input = readLine(), let val = Double(input), val >= 0 {
            return val
        }
        print("Invalid input. Enter a non-negative number.")
    }
}

func getInt(prompt: String, min: Int = 1) -> Int {
    while true {
        print(prompt, terminator: "")
        if let input = readLine(), let val = Int(input), val >= min {
            return val
        }
        print("Invalid input. Enter an integer >= \(min).")
    }
}

func getChoice(prompt: String, options: [String]) -> String {
    while true {
        print(prompt, terminator: "")
        if let input = readLine()?.trimmingCharacters(in: .whitespaces).lowercased(),
           options.contains(input) {
            return input
        }
        print("Valid options: \(options.joined(separator: ", "))")
    }
}

struct YearData {
    var year: Int
    var balance: Double
    var deposited: Double
    var interest: Double
    var tax: Double
}

struct Result {
    var initial: Double
    var totalDeposited: Double
    var totalInterestGross: Double
    var tax: Double
    var interestAfterTax: Double
    var finalBalanceNominal: Double
    var realBalance: Double
    var yearly: [YearData]
}

func calcDeposit(initial: Double, rate: Double, months: Int, capFreq: String, monthlyContrib: Double, inflation: Double, tax: Double) -> Result {
    let periodsPerYear = capFreq == "monthly" ? 12 : capFreq == "quarterly" ? 4 : 1
    let ratePerPeriod = rate / 100.0 / Double(periodsPerYear)
    let periodLength = 12 / periodsPerYear

    var balance = initial
    var totalDeposited = initial
    var totalInterest = 0.0
    var yearly: [YearData] = []
    var monthCounter = 0
    var currentYear = 1
    var yearDeposits = initial
    var yearInterest = 0.0

    for m in 1...months {
        if monthlyContrib > 0 {
            balance += monthlyContrib
            totalDeposited += monthlyContrib
            yearDeposits += monthlyContrib
        }
        monthCounter += 1
        if monthCounter % periodLength == 0 || m == months {
            let interest = balance * ratePerPeriod
            balance += interest
            totalInterest += interest
            yearInterest += interest
            monthCounter = 0
        }
        if m % 12 == 0 || m == months {
            yearly.append(YearData(
                year: currentYear,
                balance: balance,
                deposited: yearDeposits,
                interest: yearInterest,
                tax: yearInterest * (tax / 100.0)
            ))
            currentYear += 1
            yearDeposits = 0.0
            yearInterest = 0.0
        }
    }

    let totalTax = totalInterest * (tax / 100.0)
    let interestAfterTax = totalInterest - totalTax
    let finalBalance = balance
    let realBalance = finalBalance / pow(1 + inflation / 100.0, Double(months) / 12.0)

    return Result(
        initial: initial,
        totalDeposited: totalDeposited,
        totalInterestGross: totalInterest,
        tax: totalTax,
        interestAfterTax: interestAfterTax,
        finalBalanceNominal: finalBalance,
        realBalance: realBalance,
        yearly: yearly
    )
}

func printReport(_ result: Result, rate: Double, months: Int, capChoice: String, monthlyContrib: Double, inflation: Double, tax: Double) {
    print("\n--- REPORT ---")
    print(String(format: "Initial deposit:       $%.2f", result.initial))
    print("Term:                  \(months) months")
    print(String(format: "Interest rate:         %.2f%% p.a.", rate))
    print("Capitalization:        \(capChoice)")
    print(String(format: "Monthly contribution:  $%.2f", monthlyContrib))
    print(String(format: "Inflation:             %.2f%% p.a.", inflation))
    print(String(format: "Tax on interest:       %.2f%%", tax))
    print()
    print(String(format: "Final balance (nominal):   $%.2f", result.finalBalanceNominal))
    print(String(format: "Total interest (gross):    $%.2f", result.totalInterestGross))
    print(String(format: "Tax on interest:           $%.2f", result.tax))
    print(String(format: "Interest after tax:        $%.2f", result.interestAfterTax))
    print(String(format: "Real balance (inflation):  $%.2f", result.realBalance))

    print("\nYear-by-year breakdown:")
    print(String(format: "%-6s %-12s %-12s %-12s %-10s", "Year", "Balance", "Deposited", "Interest", "Tax"))
    for y in result.yearly {
        print(String(format: "%-6d $%-11.2f $%-11.2f $%-11.2f $%-9.2f", y.year, y.balance, y.deposited, y.interest, y.tax))
    }

    if !result.yearly.isEmpty {
        let maxBal = result.yearly.map { $0.balance }.max()!
        let width = 40
        print("\nBalance growth chart (nominal):")
        for y in result.yearly {
            let barLen = Int((y.balance / maxBal) * Double(width))
            let bar = String(repeating: "█", count: barLen)
            print(String(format: "Year %d: %@ %.2f", y.year, bar, y.balance))
        }
    }
}

func main() {
    print("=== Deposit Yield Calculator ===")
    let initial = getFloat(prompt: "Initial deposit: ")
    let rate = getFloat(prompt: "Annual interest rate (%): ")
    let months = getInt(prompt: "Term (months): ", min: 1)
    let capChoice = getChoice(prompt: "Capitalization frequency (monthly/quarterly/yearly): ", options: ["monthly", "quarterly", "yearly"])
    let monthlyContrib = getFloat(prompt: "Monthly contribution (0 if none): ")
    let inflation = getFloat(prompt: "Inflation rate (% per year): ")
    let tax = getFloat(prompt: "Tax on interest (%): ")

    let result = calcDeposit(initial: initial, rate: rate, months: months, capFreq: capChoice, monthlyContrib: monthlyContrib, inflation: inflation, tax: tax)
    printReport(result, rate: rate, months: months, capChoice: capChoice, monthlyContrib: monthlyContrib, inflation: inflation, tax: tax)
}

main()
