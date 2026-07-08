# deposit_calculator.py
import math
from enum import Enum

class CapFreq(Enum):
    MONTHLY = 12
    QUARTERLY = 4
    YEARLY = 1

def get_float(prompt):
    while True:
        try:
            val = float(input(prompt))
            if val >= 0:
                return val
            print("Value must be non-negative.")
        except ValueError:
            print("Invalid input. Enter a number.")

def get_int(prompt, min_val=1):
    while True:
        try:
            val = int(input(prompt))
            if val >= min_val:
                return val
            print(f"Value must be at least {min_val}.")
        except ValueError:
            print("Invalid input. Enter an integer.")

def get_choice(prompt, options):
    while True:
        val = input(prompt).strip().lower()
        if val in options:
            return val
        print(f"Valid options: {', '.join(options)}")

def calc_deposit(initial, rate, months, cap_freq, monthly_contrib, inflation, tax):
    # Convert rate to monthly
    periods_per_year = cap_freq.value
    rate_per_period = rate / 100 / periods_per_year
    total_periods = months / (12 / periods_per_year)  # number of compounding periods
    total_periods = int(round(total_periods))

    balance = initial
    total_deposited = initial
    total_interest_gross = 0.0
    yearly_data = []

    # We'll compute period by period, but also collect yearly balances for chart.
    # For simplicity, we'll iterate months and apply compounding at period boundaries.
    # Better: compute month by month and capitalize at period end.
    month_counter = 0
    current_year = 1
    year_start_balance = initial
    year_interest = 0.0
    year_deposits = initial  # initial deposit counts as year 1 deposits

    for m in range(1, months + 1):
        # Add monthly contribution at start of month (if any)
        if monthly_contrib > 0:
            balance += monthly_contrib
            total_deposited += monthly_contrib
            year_deposits += monthly_contrib

        # Check if we need to capitalize at end of month?
        # Capitalization occurs at end of each period (monthly if cap_freq monthly, etc.)
        # We'll accumulate interest daily? Actually simpler: compute monthly interest,
        # but only add to balance at capitalization periods.
        # We'll compute interest for this month: balance * (rate / 12 / 100)
        # But if we compound only at periods, we need to accumulate interest separately.
        # We'll use formula: at each period, balance += balance * rate_per_period.
        # However, with monthly contributions, we need to treat each period.
        # We'll do period-based: each period, add contributions (monthly * number of months in period),
        # then apply interest.
        # But easier: loop month by month, and at the end of each capitalization period,
        # add interest for that period.
        # We'll use a month counter to know when to capitalize.

        month_counter += 1
        # After adding contribution, if month_counter == period_length (in months) or end of term,
        # then apply interest for that period.
        period_length = 12 // periods_per_year  # months per period
        if month_counter % period_length == 0 or m == months:
            # interest for the period: balance * rate_per_period
            interest = balance * rate_per_period
            balance += interest
            total_interest_gross += interest
            year_interest += interest
            month_counter = 0  # reset

        # Check if we moved to next year (for yearly report)
        if m % 12 == 0 or m == months:
            # end of year
            final_balance_this_year = balance
            yearly_data.append({
                'year': current_year,
                'balance': final_balance_this_year,
                'deposited': year_deposits,
                'interest': year_interest,
                'tax': year_interest * (tax / 100)
            })
            current_year += 1
            year_start_balance = balance
            year_interest = 0.0
            year_deposits = 0.0

    total_tax = total_interest_gross * (tax / 100)
    interest_after_tax = total_interest_gross - total_tax
    final_balance_nominal = balance
    # Real balance: adjust for inflation over the whole term
    real_balance = final_balance_nominal / ((1 + inflation/100) ** (months/12))

    return {
        'initial': initial,
        'total_deposited': total_deposited,
        'total_interest_gross': total_interest_gross,
        'tax': total_tax,
        'interest_after_tax': interest_after_tax,
        'final_balance_nominal': final_balance_nominal,
        'real_balance': real_balance,
        'yearly': yearly_data
    }

def print_report(result, rate, months, cap_freq, monthly_contrib, inflation, tax):
    print("\n--- REPORT ---")
    print(f"Initial deposit:       ${result['initial']:.2f}")
    print(f"Term:                  {months} months")
    print(f"Interest rate:         {rate:.2f}% p.a.")
    print(f"Capitalization:        {cap_freq}")
    print(f"Monthly contribution:  ${monthly_contrib:.2f}")
    print(f"Inflation:             {inflation:.2f}% p.a.")
    print(f"Tax on interest:       {tax:.2f}%")
    print()
    print(f"Final balance (nominal):   ${result['final_balance_nominal']:.2f}")
    print(f"Total interest (gross):    ${result['total_interest_gross']:.2f}")
    print(f"Tax on interest:           ${result['tax']:.2f}")
    print(f"Interest after tax:        ${result['interest_after_tax']:.2f}")
    print(f"Real balance (inflation):  ${result['real_balance']:.2f}")

    # Yearly table
    print("\nYear-by-year breakdown:")
    print(f"{'Year':<6} {'Balance':<12} {'Deposited':<12} {'Interest':<12} {'Tax':<10}")
    for y in result['yearly']:
        print(f"{y['year']:<6} ${y['balance']:<11.2f} ${y['deposited']:<11.2f} ${y['interest']:<11.2f} ${y['tax']:<9.2f}")

    # ASCII chart (just balance over years)
    if result['yearly']:
        max_balance = max(y['balance'] for y in result['yearly'])
        width = 40
        print("\nBalance growth chart (nominal):")
        for y in result['yearly']:
            bar_len = int((y['balance'] / max_balance) * width)
            bar = '█' * bar_len
            print(f"Year {y['year']}: {bar} {y['balance']:.2f}")

def main():
    print("=== Deposit Yield Calculator ===")
    initial = get_float("Initial deposit: ")
    rate = get_float("Annual interest rate (%): ")
    months = get_int("Term (months): ", 1)
    cap_choice = get_choice("Capitalization frequency (monthly/quarterly/yearly): ", ['monthly','quarterly','yearly'])
    cap_map = {'monthly': CapFreq.MONTHLY, 'quarterly': CapFreq.QUARTERLY, 'yearly': CapFreq.YEARLY}
    cap_freq = cap_map[cap_choice]
    monthly_contrib = get_float("Monthly contribution (0 if none): ")
    inflation = get_float("Inflation rate (% per year): ")
    tax = get_float("Tax on interest (%): ")

    result = calc_deposit(initial, rate, months, cap_freq, monthly_contrib, inflation, tax)
    print_report(result, rate, months, cap_choice, monthly_contrib, inflation, tax)

if __name__ == "__main__":
    main()
