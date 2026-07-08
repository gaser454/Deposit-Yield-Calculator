# 📈 Deposit Yield Calculator – Multi‑Language Edition

A professional‑grade **deposit profitability calculator** that accounts for compound interest, periodic contributions, inflation, and taxes.  
Implemented in **7 programming languages** to demonstrate clean code, financial math, and interactive CLI.

## ✨ Features
- **Compound interest** – monthly, quarterly, or annual capitalization.
- **Regular contributions** – add or withdraw a fixed amount each month.
- **Inflation adjustment** – see real (inflation‑adjusted) final balance.
- **Tax on interest** – apply a tax rate (e.g., 13%) to the earned interest.
- **Detailed report** – shows:
  - Final balance (nominal and real)
  - Total interest earned (gross and net of tax)
  - Year‑by‑year breakdown table
  - ASCII bar chart of balance growth over time
- **Interactive input** – guided prompts with validation.

## 🗂 Languages & Files
| Language          | File                        |
|-------------------|-----------------------------|
| Python            | `deposit_calculator.py`     |
| Go                | `deposit_calculator.go`     |
| JavaScript (Node) | `deposit_calculator.js`     |
| C#                | `DepositCalculator.cs`      |
| Java              | `DepositCalculator.java`    |
| Ruby              | `deposit_calculator.rb`     |
| Swift             | `deposit_calculator.swift`  |

## 🚀 How to Run
Each file is standalone – run with the appropriate interpreter or compiler:

| Language | Command |
|----------|---------|
| Python   | `python deposit_calculator.py` |
| Go       | `go run deposit_calculator.go` |
| JavaScript | `node deposit_calculator.js` |
| C#       | `dotnet run` (or `csc DepositCalculator.cs`) |
| Java     | `javac DepositCalculator.java && java DepositCalculator` |
| Ruby     | `ruby deposit_calculator.rb` |
| Swift    | `swift deposit_calculator.swift` |

## 📊 Example Output (partial)
=== Deposit Yield Calculator ===
Initial deposit: 1000
Annual interest rate (%): 5
Term (months): 24
Capitalization frequency (monthly/quarterly/yearly): monthly
Monthly contribution (0 if none): 100
Inflation rate (% per year): 2
Tax on interest (%): 13

--- REPORT ---
Initial deposit: $1000.00
Term: 24 months
Interest rate: 5.00% p.a.
Capitalization: monthly
Monthly contribution: $100.00
Inflation: 2.00% p.a.
Tax on interest: 13.00%

Final balance (nominal): $2362.41
Total interest (gross): $362.41
Tax on interest: $47.11
Interest after tax: $315.30
Real balance (inflation): $2265.12

Year-by-year:
Year Balance Deposited Interest Tax
1 $1262.41 $1200.00 $162.41 $21.11
2 $2362.41 $2400.00 $362.41 $47.11

Balance growth chart (nominal):
Year 1: ████████░░░░ 1262.41
Year 2: ████████████ 2362.41

text

## 💾 No external files – all calculations are done in memory.

## 🤝 Contributing
Improvements, additional languages, or more advanced financial models are welcome – open a PR!

## 📜 License
MIT – use freely.
