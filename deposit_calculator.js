// deposit_calculator.js
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function getFloat(prompt) {
    while (true) {
        const input = await ask(prompt);
        const val = parseFloat(input);
        if (!isNaN(val) && val >= 0) return val;
        console.log('Invalid input. Enter a non-negative number.');
    }
}

async function getInt(prompt, min = 1) {
    while (true) {
        const input = await ask(prompt);
        const val = parseInt(input);
        if (!isNaN(val) && val >= min) return val;
        console.log(`Invalid input. Enter an integer >= ${min}.`);
    }
}

async function getChoice(prompt, options) {
    while (true) {
        const input = (await ask(prompt)).trim().toLowerCase();
        if (options.includes(input)) return input;
        console.log(`Valid options: ${options.join(', ')}`);
    }
}

function calcDeposit(initial, rate, months, capFreq, monthlyContrib, inflation, tax) {
    const periodsPerYear = capFreq === 'monthly' ? 12 : capFreq === 'quarterly' ? 4 : 1;
    const ratePerPeriod = rate / 100 / periodsPerYear;
    const periodLength = 12 / periodsPerYear; // months per period

    let balance = initial;
    let totalDeposited = initial;
    let totalInterest = 0;
    const yearly = [];
    let monthCounter = 0;
    let currentYear = 1;
    let yearDeposits = initial;
    let yearInterest = 0;

    for (let m = 1; m <= months; m++) {
        if (monthlyContrib > 0) {
            balance += monthlyContrib;
            totalDeposited += monthlyContrib;
            yearDeposits += monthlyContrib;
        }
        monthCounter++;
        if (monthCounter % periodLength === 0 || m === months) {
            const interest = balance * ratePerPeriod;
            balance += interest;
            totalInterest += interest;
            yearInterest += interest;
            monthCounter = 0;
        }
        if (m % 12 === 0 || m === months) {
            yearly.push({
                year: currentYear,
                balance: balance,
                deposited: yearDeposits,
                interest: yearInterest,
                tax: yearInterest * (tax / 100)
            });
            currentYear++;
            yearDeposits = 0;
            yearInterest = 0;
        }
    }

    const totalTax = totalInterest * (tax / 100);
    const interestAfterTax = totalInterest - totalTax;
    const finalBalance = balance;
    const realBalance = finalBalance / Math.pow(1 + inflation/100, months/12);

    return {
        initial,
        totalDeposited,
        totalInterestGross: totalInterest,
        tax: totalTax,
        interestAfterTax,
        finalBalanceNominal: finalBalance,
        realBalance,
        yearly
    };
}

function printReport(result, rate, months, capChoice, monthlyContrib, inflation, tax) {
    console.log('\n--- REPORT ---');
    console.log(`Initial deposit:       $${result.initial.toFixed(2)}`);
    console.log(`Term:                  ${months} months`);
    console.log(`Interest rate:         ${rate.toFixed(2)}% p.a.`);
    console.log(`Capitalization:        ${capChoice}`);
    console.log(`Monthly contribution:  $${monthlyContrib.toFixed(2)}`);
    console.log(`Inflation:             ${inflation.toFixed(2)}% p.a.`);
    console.log(`Tax on interest:       ${tax.toFixed(2)}%`);
    console.log();
    console.log(`Final balance (nominal):   $${result.finalBalanceNominal.toFixed(2)}`);
    console.log(`Total interest (gross):    $${result.totalInterestGross.toFixed(2)}`);
    console.log(`Tax on interest:           $${result.tax.toFixed(2)}`);
    console.log(`Interest after tax:        $${result.interestAfterTax.toFixed(2)}`);
    console.log(`Real balance (inflation):  $${result.realBalance.toFixed(2)}`);

    console.log('\nYear-by-year breakdown:');
    console.log(`${'Year'.padEnd(6)} ${'Balance'.padEnd(12)} ${'Deposited'.padEnd(12)} ${'Interest'.padEnd(12)} ${'Tax'.padEnd(10)}`);
    for (const y of result.yearly) {
        console.log(`${y.year.toString().padEnd(6)} $${y.balance.toFixed(2).padEnd(11)} $${y.deposited.toFixed(2).padEnd(11)} $${y.interest.toFixed(2).padEnd(11)} $${y.tax.toFixed(2).padEnd(9)}`);
    }

    if (result.yearly.length > 0) {
        const maxBal = Math.max(...result.yearly.map(y => y.balance));
        const width = 40;
        console.log('\nBalance growth chart (nominal):');
        for (const y of result.yearly) {
            const barLen = Math.round((y.balance / maxBal) * width);
            const bar = '█'.repeat(barLen);
            console.log(`Year ${y.year}: ${bar} ${y.balance.toFixed(2)}`);
        }
    }
}

async function main() {
    console.log('=== Deposit Yield Calculator ===');
    const initial = await getFloat('Initial deposit: ');
    const rate = await getFloat('Annual interest rate (%): ');
    const months = await getInt('Term (months): ', 1);
    const capChoice = await getChoice('Capitalization frequency (monthly/quarterly/yearly): ', ['monthly', 'quarterly', 'yearly']);
    const monthlyContrib = await getFloat('Monthly contribution (0 if none): ');
    const inflation = await getFloat('Inflation rate (% per year): ');
    const tax = await getFloat('Tax on interest (%): ');

    const result = calcDeposit(initial, rate, months, capChoice, monthlyContrib, inflation, tax);
    printReport(result, rate, months, capChoice, monthlyContrib, inflation, tax);
    rl.close();
}

main().catch(console.error);
