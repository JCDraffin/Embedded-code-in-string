module parser.utility.number;

public static bool hasNumber(string[] samples, bool debugFlag = false)
{
    import std.conv;
    import std.string;

    foreach (sample; samples)
    {
        if (sample.isNumeric)
            return true;
    }
    // return getNumber(samples).length != 0; // checks if the sample string will produce at least 1 number. 
    return false; // checks if the sample string will produce at least 1 number. 

}

public static double[] getNumber(string[] samples, bool debugFlag = false)
{
    string[] buffer = []; //string in the correct format to convert

    const MAXIMUM_DECIMAL_DELIMITER = 1;
    bool isNumber = false;
    foreach (sample; samples)
    {
        import std.string;

        sample = sample.strip(); //removes white spaces from the left and right ends.
        isNumber = sample.count('.') <= MAXIMUM_DECIMAL_DELIMITER; //checks if the possible number has 0, or 1 decimal.
        foreach (symbol; sample)
        {
            if (!isNumber)
                break; //We run the check first for optimization reasons. 

            import std.ascii;

            isNumber = isNumber && (symbol.isDigit() || symbol == '.'); //is number, if it was a number, and has a digit or period. 
        }
        if (isNumber)
            buffer ~= sample; //we've prove it's a number so add it to the buffer list for conversion. 
    }
    double[] result;
    import std.conv;
    import std.algorithm;
    import std.algorithm.comparison;
    import std.string;
    import std.array;

    auto sum = buffer.filter!(a => a.isNumeric).array;
    result.length = sum.length;
    import std.stdio;

    foreach (i, ref key; sum)
    {
        result[i] = to!double(key);
    }
    return result;
}

unittest  //hasNumber fail
{

    import std.stdio;

    assert(!hasNumber(["This "])); //false: No integer exist
    assert(!hasNumber(["This ", " Will ", " Fail", "!"])); //false: No integer exist
    assert(!hasNumber(["This2 ", " Wi3ll ", " Fa4il", "!5"])); //false: integer follows a symbol thus not a valid number.
    assert(!hasNumber(["3This ", "4 Will ", " fFail", "23232!"])); //false: integer precedes a symbol, thus not a valid number.
    assert(!hasNumber(["1,000"])); //false BUT SHOULD IT? delimiters not supported

    assert(hasNumber(["This ", " Will ", "not", " Fail", "1"])); //true: at least one number is just a number
    assert(hasNumber(["3443 ", " 533 ", " 35353", "5353535", "1"])); //true: all these are numbers
    assert(!hasNumber(["3,443 ", " 35,353", "5,353,535"])); //false: numbers with delimiters aren't valid.
    assert(hasNumber(["3.14 "])); //true decimal numbers are valid numbers.
    assert(hasNumber(["3.443 ", " 35.353", "5.353535"])); //true decimal numbers are valid numbers.

    assert(hasNumber(["   1234567890"])); //true: white space in front of number is ignored/stripped, thus valid
    assert(hasNumber(["1234567890    "])); //true: white space behind number is ignored/stripped, thus valid
    assert(hasNumber(["   1234567890      "])); //true: whitespace in front and behind number is ignore/stripped, thus valid
    assert(!hasNumber(["   12345   67890      "])); //false: white space between two numbers is not valid.
    assert(!hasNumber(["12345   67890      "])); //false: white space between two numbers is not valid.
    assert(!hasNumber(["   12345   67890"])); //false: white space between two numbers is not valid.

}

unittest  //hasNumber fail
{

    import std.stdio;

    assert(!hasNumber(["This "])); //false: No integer exist
    assert(!hasNumber(["This ", " Will ", " Fail", "!"])); //false: No integer exist
    assert(!hasNumber(["This2 ", " Wi3ll ", " Fa4il", "!5"])); //false: integer follows a symbol thus not a valid number.
    assert(!hasNumber(["3This ", "4 Will ", " fFail", "23232!"])); //false: integer proceeds a symbol, thus not a valid number.
    assert(!hasNumber(["1,000"])); //false BUT SHOULD IT? delimiters not supported

    assert(hasNumber(["This ", " Will ", "not", " Fail", "1"])); //true: at least one number is just a number
    assert(hasNumber(["3443 ", " 533 ", " 35353", "5353535", "1"])); //true: all these are numbers
    assert(!hasNumber(["3,443 ", " 35,353", "5,353,535"])); //false: numbers with delimiters aren't valid.
    assert(hasNumber(["3.14 "])); //true decimal numbers are valid numbers.
    assert(hasNumber(["3.443 ", " 35.353", "5.353535"])); //true decimal numbers are valid numbers.

    assert(hasNumber(["   1234567890"])); //true: white space in front of number is ignored/stripped, thus valid
    assert(hasNumber(["1234567890    "])); //true: white space behind number is ignored/stripped, thus valid
    assert(hasNumber(["   1234567890      "])); //true: whitespace in front and behind number is ignore/stripped, thus valid
    assert(!hasNumber(["   12345   67890      "])); //false: white space between two numbers is not valid.
    assert(!hasNumber(["12345   67890      "])); //false: white space between two numbers is not valid.
    assert(!hasNumber(["   12345   67890"])); //false: white space between two numbers is not valid.

}
