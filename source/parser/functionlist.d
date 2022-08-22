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
private const ubyte members2Ignore = 8;

/++ 
 + Use to initialize the singleton 
 + Returns: AA of all functions descriptions.
 +/
private string[string] init_funcDesc()
{
    string[string] list;
    foreach (i, name; __traits(allMembers, parser.functionlist)) //writeln( &__traits(getMember, funclist, name));//  getUDAs!(name)[0] );
    {

        static if (i > members2Ignore)
        {
            auto buffer = __traits(getAttributes, __traits(getMember, parser.functionlist, name));
            static if (buffer.length != 0)
            {
                //         // writeln("@A: ", &__traits(getAttributes, &__traits(getMember, parser.functionlist, name)[0]));
                list[name] = buffer[0];
            }
        }
    }

    return list;
}

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

private string[string] _funcDesc;
private string function(string[])[string] _instances;

/++
 +Returns: description for all delegates that are whitelisted for parser and have a description
 +/
public string[string] funcDesc()
{
    if (_funcDesc is null)
        _funcDesc = init_funcDesc;
    return _funcDesc;

}

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

@("Finds minimum value of all arguments. Non-numeric are ignored") string min(string[] value)
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

@("Finds maximum value of all arguments. Non-numeric are ignored") string max(string[] value)
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

@("Adds values together. Non-numeric are ignored") string add(string[] value)
{
    import parser.utility.number;
    import std.conv;
    import std.algorithm.iteration;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer = 0;

    buffer = numbers.fold!((a, b) => a + b);

    return to!string(buffer);

}

//Bug? Should sub(2,2) be [0 or 2-2], or [-4 or -2-2] 
@("Subtracts values together. Non-numeric are ignored") string sub(string[] value)
{

    import parser.utility.number;
    import std.conv;
    import std.algorithm.iteration;

    if (!hasNumber(value))
        return "0";
    double[] numbers = (0 ~ getNumber(value)); //We have to add 0 to the front, so the values are subtracted correctly.
    double buffer;
    buffer = numbers.fold!((a, b) => a - b);

    return to!string(buffer);

}

@("Divide values. Non-numeric are ignored") string div(string[] value)
{
    import parser.utility.number;
    import std.conv;
    import std.algorithm.iteration;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer;
    buffer = numbers.fold!((a, b) => a / b);

    return to!string(buffer);
}

@("Multiply values together. Non-numeric are ignored") string mul(string[] value)
{
    import parser.utility.number;
    import std.conv;
    import std.algorithm.iteration;

    if (!hasNumber(value))
        return "0";
    double[] numbers = getNumber(value);
    double buffer;
    buffer = numbers.fold!((a, b) => a * b);

    return to!string(buffer);

}

@("Combined passed in values into a single result. @cat('2','3') will become '23'") string concat(
    string[] value)
{
    string buffer = "";

    foreach (key; value)
    {
        buffer ~= key;
    }
    return buffer;
}

@("Prints out a list of functions and description") string help(string[] value)
{
    return helplist(value);
}

@("Prints out a list of functions and description") string helplist(string[] value)
{
    auto desc = funcDesc; //gets the cached results for function description
    auto func = instance; //gets the cached function delegates

    import std.conv;
    import std.array;

    immutable ulong lettercount = to!ulong(cl(func.byKey.array)); //calculates the largest function name is, by checking the key.
    string result;
    foreach (name; func.byKey)
    {
        auto element = desc.require(name, ""); //caches the description for the current function.
        if (element != "") //checks if we have a valid desciption 
        {
            import std.format;

            result ~= format!"%.*s%*s: %s\n"(lettercount, name, lettercount - name.length, "", element);
        }
    }

    return result;
}

@("returns the character count of the largest argument") string cl(string[] value)
{
    ulong max = 0;
    foreach (key; value)
    {
        max = key.length > max ? key.length : max;
    }

    import std.conv;

    return to!string(max);
}

@("Prints out a list of functions") string funclist(string[] value)
{
    import std.format;

    auto list = instance();
    import std.array;

    return format("%s", list.byKey.array);

}

@("Prints out a list of functions and object id") string funclistWithID(string[] value)
{
    import std.format;

    auto list = instance();
    return format("%s", list);

}
