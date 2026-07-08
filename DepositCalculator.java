// DepositCalculator.java
import java.util.*;

public class DepositCalculator {
    private static Scanner scanner = new Scanner(System.in);

    private static double getFloat(String prompt) {
        while (true) {
            System.out.print(prompt);
            if (scanner.hasNextDouble()) {
                double val = scanner.nextDouble();
                if (val >= 0) return val;
            } else {
                scanner.next();
            }
            System.out.println("Invalid input. Enter a non-negative number.");
        }
    }

    private static int getInt(String prompt, int min) {
        while (true) {
            System.out.print(prompt);
            if (scanner.hasNextInt()) {
                int val = scanner.nextInt();
                if (val >= min) return val;
            } else {
                scanner.next();
            }
            System.out.printf("Invalid input. Enter an integer >= %d.\n", min);
        }
    }

    private static String getChoice(String prompt, String[] options) {
        while (true) {
            System.out.print(prompt);
            String input = scanner.next().trim().toLowerCase();
            for (String opt : options) {
                if (opt.equals(input)) return input;
            }
            System.out.printf("Valid options: %s\n", String.join(", ", options));
        }
    }

    static class YearData {
        int year;
        double balance;
        double deposited;
        double interest;
        double tax;
    }

    static class Result {
        double initial;
        double totalDeposited;
        double totalInterestGross;
        double tax;
        double interestAfterTax;
        double finalBalanceNominal;
        double realBalance;
        List<YearData> yearly = new ArrayList<>();
    }

    private static Result calcDeposit(double initial, double rate, int months, String capFreq, double monthlyContrib, double inflation, double tax) {
        int periodsPerYear = capFreq.equals("monthly") ? 12 : capFreq.equals("quarterly") ? 4 : 1;
        double ratePerPeriod = rate / 100.0 / periodsPerYear;
        int periodLength = 12 / periodsPerYear;

        double balance = initial;
        double totalDeposited = initial;
        double totalInterest = 0;
        List<YearData> yearly = new ArrayList<>();
        int monthCounter = 0;
        int currentYear = 1;
        double yearDeposits = initial;
        double yearInterest = 0;

        for (int m = 1; m <= months; m++) {
            if (monthlyContrib > 0) {
                balance += monthlyContrib;
                totalDeposited += monthlyContrib;
                yearDeposits += monthlyContrib;
            }
            monthCounter++;
            if (monthCounter % periodLength == 0 || m == months) {
                double interest = balance * ratePerPeriod;
                balance += interest;
                totalInterest += interest;
                yearInterest += interest;
                monthCounter = 0;
            }
            if (m % 12 == 0 || m == months) {
                YearData yd = new YearData();
                yd.year = currentYear;
                yd.balance = balance;
                yd.deposited = yearDeposits;
                yd.interest = yearInterest;
                yd.tax = yearInterest * (tax / 100.0);
                yearly.add(yd);
                currentYear++;
                yearDeposits = 0;
                yearInterest = 0;
            }
        }

        double totalTax = totalInterest * (tax / 100.0);
        double interestAfterTax = totalInterest - totalTax;
        double finalBalance = balance;
        double realBalance = finalBalance / Math.pow(1 + inflation / 100.0, months / 12.0);

        Result res = new Result();
        res.initial = initial;
        res.totalDeposited = totalDeposited;
        res.totalInterestGross = totalInterest;
        res.tax = totalTax;
        res.interestAfterTax = interestAfterTax;
        res.finalBalanceNominal = finalBalance;
        res.realBalance = realBalance;
        res.yearly = yearly;
        return res;
    }

    private static void printReport(Result result, double rate, int months, String capChoice, double monthlyContrib, double inflation, double tax) {
        System.out.println("\n--- REPORT ---");
        System.out.printf("Initial deposit:       $%.2f\n", result.initial);
        System.out.printf("Term:                  %d months\n", months);
        System.out.printf("Interest rate:         %.2f%% p.a.\n", rate);
        System.out.printf("Capitalization:        %s\n", capChoice);
        System.out.printf("Monthly contribution:  $%.2f\n", monthlyContrib);
        System.out.printf("Inflation:             %.2f%% p.a.\n", inflation);
        System.out.printf("Tax on interest:       %.2f%%\n", tax);
        System.out.println();
        System.out.printf("Final balance (nominal):   $%.2f\n", result.finalBalanceNominal);
        System.out.printf("Total interest (gross):    $%.2f\n", result.totalInterestGross);
        System.out.printf("Tax on interest:           $%.2f\n", result.tax);
        System.out.printf("Interest after tax:        $%.2f\n", result.interestAfterTax);
        System.out.printf("Real balance (inflation):  $%.2f\n", result.realBalance);

        System.out.println("\nYear-by-year breakdown:");
        System.out.printf("%-6s %-12s %-12s %-12s %-10s\n", "Year", "Balance", "Deposited", "Interest", "Tax");
        for (YearData y : result.yearly) {
            System.out.printf("%-6d $%-11.2f $%-11.2f $%-11.2f $%-9.2f\n", y.year, y.balance, y.deposited, y.interest, y.tax);
        }

        if (!result.yearly.isEmpty()) {
            double maxBal = result.yearly.stream().mapToDouble(y -> y.balance).max().getAsDouble();
            int width = 40;
            System.out.println("\nBalance growth chart (nominal):");
            for (YearData y : result.yearly) {
                int barLen = (int)((y.balance / maxBal) * width);
                String bar = "█".repeat(Math.max(0, barLen));
                System.out.printf("Year %d: %s %.2f\n", y.year, bar, y.balance);
            }
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Deposit Yield Calculator ===");
        double initial = getFloat("Initial deposit: ");
        double rate = getFloat("Annual interest rate (%): ");
        int months = getInt("Term (months): ", 1);
        String capChoice = getChoice("Capitalization frequency (monthly/quarterly/yearly): ", new String[]{"monthly", "quarterly", "yearly"});
        double monthlyContrib = getFloat("Monthly contribution (0 if none): ");
        double inflation = getFloat("Inflation rate (% per year): ");
        double tax = getFloat("Tax on interest (%): ");

        Result result = calcDeposit(initial, rate, months, capChoice, monthlyContrib, inflation, tax);
        printReport(result, rate, months, capChoice, monthlyContrib, inflation, tax);
        scanner.close();
    }
}
