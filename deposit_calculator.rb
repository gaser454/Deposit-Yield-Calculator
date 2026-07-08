# deposit_calculator.rb
def get_float(prompt)
  loop do
    print prompt
    input = gets.chomp
    val = Float(input) rescue nil
    if val && val >= 0
      return val
    else
      puts "Invalid input. Enter a non-negative number."
    end
  end
end

def get_int(prompt, min=1)
  loop do
    print prompt
    input = gets.chomp
    val = Integer(input) rescue nil
    if val && val >= min
      return val
    else
      puts "Invalid input. Enter an integer >= #{min}."
    end
  end
end

def get_choice(prompt, options)
  loop do
    print prompt
    input = gets.chomp.strip.downcase
    if options.include?(input)
      return input
    else
      puts "Valid options: #{options.join(', ')}"
    end
  end
end

def calc_deposit(initial, rate, months, cap_freq, monthly_contrib, inflation, tax)
  periods_per_year = case cap_freq
                     when 'monthly' then 12
                     when 'quarterly' then 4
                     else 1
                     end
  rate_per_period = rate / 100.0 / periods_per_year
  period_length = 12 / periods_per_year

  balance = initial
  total_deposited = initial
  total_interest = 0.0
  yearly = []
  month_counter = 0
  current_year = 1
  year_deposits = initial
  year_interest = 0.0

  (1..months).each do |m|
    if monthly_contrib > 0
      balance += monthly_contrib
      total_deposited += monthly_contrib
      year_deposits += monthly_contrib
    end
    month_counter += 1
    if month_counter % period_length == 0 || m == months
      interest = balance * rate_per_period
      balance += interest
      total_interest += interest
      year_interest += interest
      month_counter = 0
    end
    if m % 12 == 0 || m == months
      yearly << {
        year: current_year,
        balance: balance,
        deposited: year_deposits,
        interest: year_interest,
        tax: year_interest * (tax / 100.0)
      }
      current_year += 1
      year_deposits = 0.0
      year_interest = 0.0
    end
  end

  total_tax = total_interest * (tax / 100.0)
  interest_after_tax = total_interest - total_tax
  final_balance = balance
  real_balance = final_balance / (1 + inflation/100.0) ** (months / 12.0)

  {
    initial: initial,
    total_deposited: total_deposited,
    total_interest_gross: total_interest,
    tax: total_tax,
    interest_after_tax: interest_after_tax,
    final_balance_nominal: final_balance,
    real_balance: real_balance,
    yearly: yearly
  }
end

def print_report(result, rate, months, cap_choice, monthly_contrib, inflation, tax)
  puts "\n--- REPORT ---"
  puts "Initial deposit:       $#{'%.2f' % result[:initial]}"
  puts "Term:                  #{months} months"
  puts "Interest rate:         #{'%.2f' % rate}% p.a."
  puts "Capitalization:        #{cap_choice}"
  puts "Monthly contribution:  $#{'%.2f' % monthly_contrib}"
  puts "Inflation:             #{'%.2f' % inflation}% p.a."
  puts "Tax on interest:       #{'%.2f' % tax}%"
  puts
  puts "Final balance (nominal):   $#{'%.2f' % result[:final_balance_nominal]}"
  puts "Total interest (gross):    $#{'%.2f' % result[:total_interest_gross]}"
  puts "Tax on interest:           $#{'%.2f' % result[:tax]}"
  puts "Interest after tax:        $#{'%.2f' % result[:interest_after_tax]}"
  puts "Real balance (inflation):  $#{'%.2f' % result[:real_balance]}"

  puts "\nYear-by-year breakdown:"
  puts "%-6s %-12s %-12s %-12s %-10s" % ["Year", "Balance", "Deposited", "Interest", "Tax"]
  result[:yearly].each do |y|
    puts "%-6d $%-11.2f $%-11.2f $%-11.2f $%-9.2f" % [y[:year], y[:balance], y[:deposited], y[:interest], y[:tax]]
  end

  if result[:yearly].any?
    max_bal = result[:yearly].map { |y| y[:balance] }.max
    width = 40
    puts "\nBalance growth chart (nominal):"
    result[:yearly].each do |y|
      bar_len = ((y[:balance] / max_bal) * width).to_i
      bar = '█' * bar_len
      puts "Year #{y[:year]}: #{bar} #{'%.2f' % y[:balance]}"
    end
  end
end

def main
  puts "=== Deposit Yield Calculator ==="
  initial = get_float("Initial deposit: ")
  rate = get_float("Annual interest rate (%): ")
  months = get_int("Term (months): ", 1)
  cap_choice = get_choice("Capitalization frequency (monthly/quarterly/yearly): ", ['monthly','quarterly','yearly'])
  monthly_contrib = get_float("Monthly contribution (0 if none): ")
  inflation = get_float("Inflation rate (% per year): ")
  tax = get_float("Tax on interest (%): ")

  result = calc_deposit(initial, rate, months, cap_choice, monthly_contrib, inflation, tax)
  print_report(result, rate, months, cap_choice, monthly_contrib, inflation, tax)
end

main if __FILE__ == $0
