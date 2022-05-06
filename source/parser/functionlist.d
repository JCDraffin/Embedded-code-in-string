/++ 
 + All appending functions in this module will be added to parser's, function list.
 + Please do no edit the location of the following code. Ignoring this instruction may cause compilation errors.
 + Please follow the function blueprint to keep the application compiling
 + 
 + Compilation Requirements:
 + Return type: must be 'string'
 + Parameters type: must be 'string[]' with variable name of value //is parameter the right word, or is it argument?
 +
 + Runtime Requirements: // All functions must run without exception error
 + No function may return a null value!
 + Must have a result if 'string[] value' length == 0. 
 + Must have a result if 'string[] value' length != 0. 
 + If a function's logic assumes all elements are number, then when an element is not a number, the function must return a string error, or a filter out the bad element
 + 
 + It is acceptable to return an error result if given bad data! 
 +/
module parser.functionlist;
///////////////////////////////////////////////////////////////
//=SETUP CODE! DON'T TOUCH! APPEND YOUR CODE TO END OF FILE!=//
///////////////////////////////////////////////////////////////

/++ 
 * Number functions, imports, and variables to ignore in the allMembers, __trait.
 +/
private const ubyte members2Ignore = 5;

/++ 
 + Use to initialize the singleton 
 + Returns: AA of all parser functions.
 +/
private string function(string[])[string] init_instance()
{
    string function(string[])[string] list;
    foreach (i, name; __traits(allMembers, parser.functionlist)) //writeln( &__traits(getMember, funclist, name));//  getUDAs!(name)[0] );
    {
        static if (i > members2Ignore)
        {

            list[name] = &__traits(getMember, parser.functionlist, name);
        }
    }

    return list;
}

private string function(string[])[string] _instances;

/++ 
 + Returns: a whitelist of delegates the parser is allowed to use. 
 +/
public string function(string[])[string] instance()
{
    if (_instances is null)
        _instances = init_instance;
    return _instances;

}

public void debugPrintAllMembers()
{
    foreach (i, name; __traits(allMembers, parser.functionlist))
    {
        import std.stdio : writeln;

        writeln(name, ": ", i);
    }

}

///////////////////////////////////////////////////////////////
//================ Add code below this point!================//
///////////////////////////////////////////////////////////////

string min(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "#ERROR#";
    double[] numbers = getNumber(value);
    double buffer = double.max;

    foreach (double key; numbers)
        buffer = key < buffer ? key : buffer;

    return format("%f", buffer);
}

string max(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "#ERROR#";
    double[] numbers = getNumber(value);
    double buffer = -double.max;

    foreach (double key; numbers)
        buffer = key > buffer ? key : buffer;

    return format("%f", buffer);

}

string add(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer = 0;
    foreach (double key; numbers)
    {
        buffer += key;
    }
    
    return format("%f", buffer);

}

string sub(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer;
    foreach (double key; numbers)
    {
        buffer -= key;
    }

    return format("%f", buffer);

}

string div(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer;
    foreach (double key; numbers)
    {
        buffer /= key;
    }

    return format("%f", buffer);
}

string mul(string[] value)
{
    import parser.utility.number;
    import std.format;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer;
    foreach (double key; numbers)
    {
        buffer *= key;
    }

    return format("%f", buffer);

}

string concat(string[] value)
{
    string buffer = "";

    foreach (key; value)
    {
        buffer ~= key;
    }
    return buffer;
}

string getUsername(string[] value)
{
    import std.stdio;
    string[] lazyLookUpTable = ["J. Draffin"];

    import parser.utility.number;

    double[] numbers = getNumber(value);
    foreach (num; numbers)
    {
        if (num < lazyLookUpTable.length)
        {
            return lazyLookUpTable[cast(long) num];
        }

    }
    return "No value was found.";
}

string funclist(string[] value)
{
    import std.format;

    auto list = instance();
    return format("%s", list);

}
