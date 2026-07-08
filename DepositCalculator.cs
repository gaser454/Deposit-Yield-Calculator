// DepositCalculator.cs
using System;
using System.Collections.Generic;
using System.Linq;

class DepositCalculator
{
    static double GetFloat(string prompt)
    {
        while (true)
        {
            Console.Write(prompt);
            if (double.TryParse(Console.ReadLine(), out double val) && val >= 0)
                return val;
            Console.WriteLine("Invalid input. Enter a non-negative number.");
        }
    }

    static int GetInt(string prompt, int min = 1)
    {
        while (true)
        {
            Console.Write(prompt);
            if (int.TryParse(Console.ReadLine(), out int val) && val >= min)
                return val;
            Console.WriteLine($"Invalid input. Enter an integer >= {min}.");
        }
    }

    static string GetChoice(string prompt, string[] options)
    {
        while (true)
        {
            Console.Write(prompt);
            string input = Console.ReadLine()?.Trim().ToLower() ?? "";
            if (options.Contains(input))
                return input;
            Console.WriteLine($"Valid options: {string.Join(", ", options)}");
        }
    }

    class YearData
    {
        public int Year { get; set; }
        public double Balance { get; set; }
        public double Deposited { get; set; }
        public double Interest { get; set; }
        public double Tax { get; set; }
    }

    class Result
    {
        public double Initial { get; set; }
        public double TotalDeposited { get; set; }
        public double TotalInterestGross { get; set; }
        public double Tax { get; set; }
        public double InterestAfterTax { get; set; }
        public double FinalBalanceNominal { get; set; }
        public double RealBalance { get; set; }
        public List<YearData> Yearly { get; set; } = new List<YearData>();
    }

    static Result CalcDeposit(double initial, double rate, int months, string capFreq, double monthlyContrib, double inflation, double tax)
    {
        int periodsPerYear = capFreq == "monthly" ? 12 : capFreq == "quarterly" ? 4 : 1;
        double ratePerPeriod = rate / 100.0 / periodsPerYear;
        int periodLength = 12 / periodsPerYear; // months per period

        double balance = initial;
        double totalDeposited = initial;
        double totalInterest = 0;
        var yearly = new List<YearData>();
        int monthCounter = 0;
        int currentYear = 1;
        double yearDeposits = initial;
        double yearInterest = 0;

        for (int m = 1; m <= months; m++)
        {
            if (monthlyContrib > 0)
            {
                balance += monthlyContrib;
                totalDeposited += monthlyContrib;
                yearDeposits += monthlyContrib;
            }
            monthCounter++;
            if (monthCounter % periodLength == 0 || m == months)
            {
                double interest = balance * ratePerPeriod;
                balance += interest;
                totalInterest += interest;
                yearInterest += interest;
                monthCounter = 0;
            }
            if (m % 12 == 0 || m == months)
            {
                yearly.Add(new YearData
                {
                    Year = currentYear,
                    Balance = balance,
                    Deposited = yearDeposits,
                    Interest = yearInterest,
                    Tax = yearInterest * (tax / 100.0)
                });
                currentYear++;
                yearDeposits = 0;
                yearInterest = 0;
            }
        }

        double totalTax = totalInterest * (tax / 100.0);
        double interestAfterTax = totalInterest - totalTax;
        double finalBalance = balance;
        double realBalance = finalBalance / Math.Pow(1 + inflation / 100.0, months / 12.0);

        return new Result
        {
            Initial = initial,
            TotalDeposited = totalDeposited,
            TotalInterestGross = totalInterest,
            Tax = totalTax,
            InterestAfterTax = interestAfterTax,
            FinalBalanceNominal = finalBalance,
            RealBalance = realBalance,
            Yearly = yearly
        };
    }

    static void PrintReport(Result result, double rate, int months, string capChoice, double monthlyContrib, double inflation, double tax)
    {
        Console.WriteLine("\n--- REPORT ---");
        Console.WriteLine($"Initial deposit:       ${result.Initial:F2}");
        Console.WriteLine($"Term:                  {months} months");
        Console.WriteLine($"Interest rate:         {rate:F2}% p.a.");
        Console.WriteLine($"Capitalization:        {capChoice}");
        Console.WriteLine($"Monthly contribution:  ${monthlyContrib:F2}");
        Console.WriteLine($"Inflation:             {inflation:F2}% p.a.");
        Console.WriteLine($"Tax on interest:       {tax:F2}%");
        Console.WriteLine();
        Console.WriteLine($"Final balance (nominal):   ${result.FinalBalanceNominal:F2}");
        Console.WriteLine($"Total interest (gross):    ${result.TotalInterestGross:F2}");
        Console.WriteLine($"Tax on interest:           ${result.Tax:F2}");
        Console.WriteLine($"Interest after tax:        ${result.InterestAfterTax:F2}");
        Console.WriteLine($"Real balance (inflation):  ${result.RealBalance:F2}");

        Console.WriteLine("\nYear-by-year breakdown:");
        Console.WriteLine($"{"Year",-6} {"Balance",-12} {"Deposited",-12} {"Interest",-12} {"Tax",-10}");
        foreach (var y in result.Yearly)
        {
            Console.WriteLine($"{y.Year,-6} ${y.Balance,-11:F2} ${y.Deposited,-11:F2} ${y.Interest,-11:F2} ${y.Tax,-9:F2}");
        }

        if (result.Yearly.Count > 0)
        {
            double maxBal = result.Yearly.Max(y => y.Balance);
            int width = 40;
            Console.WriteLine("\nBalance growth chart (nominal):");
            foreach (var y in result.Yearly)
            {
                int barLen = (int)((y.Balance / maxBal) * width);
                string bar = new string('█', barLen);
                Console.WriteLine($"Year {y.Year}: {bar} {y.Balance:F2}");
            }
        }
    }

    static void Main()
    {
        Console.WriteLine("=== Deposit Yield Calculator ===");
        double initial = GetFloat("Initial deposit: ");
        double rate = GetFloat("Annual interest rate (%): ");
        int months = GetInt("Term (months): ", 1);
        string capChoice = GetChoice("Capitalization frequency (monthly/quarterly/yearly): ", new[] { "monthly", "quarterly", "yearly" });
        double monthlyContrib = GetFloat("Monthly contribution (0 if none): ");
        double inflation = GetFloat("Inflation rate (% per year): ");
        double tax = GetFloat("Tax on interest (%): ");

        Result result = CalcDeposit(initial, rate, months, capChoice, monthlyContrib, inflation, tax);
        PrintReport(result, rate, months, capChoice, monthlyContrib, inflation, tax);
    }
}
