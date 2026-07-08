// deposit_calculator.go
package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type CapFreq int

const (
	Monthly CapFreq = 12
	Quarterly CapFreq = 4
	Yearly CapFreq = 1
)

func getFloat(prompt string) float64 {
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print(prompt)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)
		val, err := strconv.ParseFloat(input, 64)
		if err == nil && val >= 0 {
			return val
		}
		fmt.Println("Invalid input. Enter a non-negative number.")
	}
}

func getInt(prompt string, min int) int {
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print(prompt)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)
		val, err := strconv.Atoi(input)
		if err == nil && val >= min {
			return val
		}
		fmt.Printf("Invalid input. Enter an integer >= %d.\n", min)
	}
}

func getChoice(prompt string, options []string) string {
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print(prompt)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(strings.ToLower(input))
		for _, opt := range options {
			if input == opt {
				return input
			}
		}
		fmt.Printf("Valid options: %s\n", strings.Join(options, ", "))
	}
}

type Result struct {
	Initial              float64
	TotalDeposited       float64
	TotalInterestGross   float64
	Tax                  float64
	InterestAfterTax     float64
	FinalBalanceNominal  float64
	RealBalance          float64
	Yearly               []YearData
}

type YearData struct {
	Year     int
	Balance  float64
	Deposited float64
	Interest float64
	Tax      float64
}

func calcDeposit(initial, rate float64, months int, capFreq CapFreq, monthlyContrib, inflation, tax float64) Result {
	periodsPerYear := int(capFreq)
	ratePerPeriod := rate / 100.0 / float64(periodsPerYear)
	totalPeriods := int(math.Round(float64(months) / (12.0 / float64(periodsPerYear))))

	balance := initial
	totalDeposited := initial
	totalInterest := 0.0
	yearly := []YearData{}

	monthCounter := 0
	currentYear := 1
	yearDeposits := initial
	yearInterest := 0.0
	periodLength := 12 / periodsPerYear // months per period

	for m := 1; m <= months; m++ {
		if monthlyContrib > 0 {
			balance += monthlyContrib
			totalDeposited += monthlyContrib
			yearDeposits += monthlyContrib
		}
		monthCounter++
		if monthCounter%periodLength == 0 || m == months {
			interest := balance * ratePerPeriod
			balance += interest
			totalInterest += interest
			yearInterest += interest
			monthCounter = 0
		}
		if m%12 == 0 || m == months {
			yearly = append(yearly, YearData{
				Year:     currentYear,
				Balance:  balance,
				Deposited: yearDeposits,
				Interest: yearInterest,
				Tax:      yearInterest * (tax / 100.0),
			})
			currentYear++
			yearDeposits = 0.0
			yearInterest = 0.0
		}
	}
	totalTax := totalInterest * (tax / 100.0)
	interestAfterTax := totalInterest - totalTax
	finalBalance := balance
	realBalance := finalBalance / math.Pow(1+inflation/100.0, float64(months)/12.0)

	return Result{
		Initial:             initial,
		TotalDeposited:      totalDeposited,
		TotalInterestGross:  totalInterest,
		Tax:                 totalTax,
		InterestAfterTax:    interestAfterTax,
		FinalBalanceNominal: finalBalance,
		RealBalance:         realBalance,
		Yearly:              yearly,
	}
}

func printReport(res Result, rate float64, months int, capChoice string, monthlyContrib, inflation, tax float64) {
	fmt.Println("\n--- REPORT ---")
	fmt.Printf("Initial deposit:       $%.2f\n", res.Initial)
	fmt.Printf("Term:                  %d months\n", months)
	fmt.Printf("Interest rate:         %.2f%% p.a.\n", rate)
	fmt.Printf("Capitalization:        %s\n", capChoice)
	fmt.Printf("Monthly contribution:  $%.2f\n", monthlyContrib)
	fmt.Printf("Inflation:             %.2f%% p.a.\n", inflation)
	fmt.Printf("Tax on interest:       %.2f%%\n", tax)
	fmt.Println()
	fmt.Printf("Final balance (nominal):   $%.2f\n", res.FinalBalanceNominal)
	fmt.Printf("Total interest (gross):    $%.2f\n", res.TotalInterestGross)
	fmt.Printf("Tax on interest:           $%.2f\n", res.Tax)
	fmt.Printf("Interest after tax:        $%.2f\n", res.InterestAfterTax)
	fmt.Printf("Real balance (inflation):  $%.2f\n", res.RealBalance)

	fmt.Println("\nYear-by-year breakdown:")
	fmt.Printf("%-6s %-12s %-12s %-12s %-10s\n", "Year", "Balance", "Deposited", "Interest", "Tax")
	for _, y := range res.Yearly {
		fmt.Printf("%-6d $%-11.2f $%-11.2f $%-11.2f $%-9.2f\n", y.Year, y.Balance, y.Deposited, y.Interest, y.Tax)
	}

	if len(res.Yearly) > 0 {
		maxBal := res.Yearly[0].Balance
		for _, y := range res.Yearly {
			if y.Balance > maxBal {
				maxBal = y.Balance
			}
		}
		width := 40
		fmt.Println("\nBalance growth chart (nominal):")
		for _, y := range res.Yearly {
			barLen := int((y.Balance / maxBal) * float64(width))
			bar := strings.Repeat("█", barLen)
			fmt.Printf("Year %d: %s %.2f\n", y.Year, bar, y.Balance)
		}
	}
}

func main() {
	fmt.Println("=== Deposit Yield Calculator ===")
	initial := getFloat("Initial deposit: ")
	rate := getFloat("Annual interest rate (%): ")
	months := getInt("Term (months): ", 1)
	capChoice := getChoice("Capitalization frequency (monthly/quarterly/yearly): ", []string{"monthly", "quarterly", "yearly"})
	var capFreq CapFreq
	switch capChoice {
	case "monthly": capFreq = Monthly
	case "quarterly": capFreq = Quarterly
	case "yearly": capFreq = Yearly
	}
	monthlyContrib := getFloat("Monthly contribution (0 if none): ")
	inflation := getFloat("Inflation rate (% per year): ")
	tax := getFloat("Tax on interest (%): ")

	res := calcDeposit(initial, rate, months, capFreq, monthlyContrib, inflation, tax)
	printReport(res, rate, months, capChoice, monthlyContrib, inflation, tax)
}
