module parser.evaluator;

public abstract class AbstractEvaluator
{
    abstract protected string errorMsg(string errorText);
    abstract protected string errorMsgFuncDoesNotExist(string funcIdentifer); // 
    abstract public string lookUpVariable(string varIdentifer);
    abstract public void setVariable(string varIdentifer, string value);
    abstract public bool lookUpFlag(string flagIdentifer);
    abstract public void setFlag(string flagIdentifer, bool value);
    abstract public string convFlag2Str(bool );
    abstract public string runCompiledFunction(string funcIdentifer, string[] arguments); //Function to send scripting language calls, into compiled language calls.
    abstract public string runCompiledDlangFunction(string funcIdentifer, string[] arguments); //Should this function even exist! 

}

public class BasicEvaluator : AbstractEvaluator
{
    const string NO_VALUE = "[NO VAL]";
    const bool DEFAULT_FLAG = false;

    private string[string] variables;
    private bool[string] flags;
    protected override string errorMsg(string errorText)

    {
        import std.format;

        return format!"<<%s>>"(errorText);
    }

    protected override string errorMsgFuncDoesNotExist(string funcIdentifer)
    {
        return errorMsg("No such function exist. Missing the function: " ~ funcIdentifer);
    }

    public override string lookUpVariable(string varIdentifer)
    {
        import std.stdio;

        string result = variables.require(varIdentifer, NO_VALUE); //gets a value, even if it's with a default value.

        return result is null ? NO_VALUE : result; //does a sanity check before returning the value with a non-null result.
    }

    unittest
    {
        BasicEvaluator BE = new BasicEvaluator();
        assert(BE.lookUpVariable("FOO") == BE.NO_VALUE);
        BE.setVariable("FOO", "BAR");
        assert(BE.lookUpVariable("FOO") == "BAR");
        BE.setVariable("FOO", "FOO");
        assert(BE.lookUpVariable("FOO") == "FOO");
        BE.setVariable("FOO", "FOO");
        assert(BE.lookUpVariable("FOO") == "FOO");
        BE.setVariable("FOO", null);
        assert(BE.lookUpVariable("FOO") == BE.NO_VALUE);
        BE.setVariable("FOO", "FOO");
        assert(BE.lookUpVariable("FOO") == "FOO");
    }

    public override void setVariable(string varIdentifer, string value)
    {

        variables[varIdentifer] = value is null ? NO_VALUE : value; //sets a variable and gives a default value when null is given.
    }

    public override bool lookUpFlag(string flagIdentifer)
    {
        bool result = flags.require(flagIdentifer, false);
        return result;
    }

    unittest
    {
        BasicEvaluator BE = new BasicEvaluator();
        assert(BE.lookUpFlag("FOO") == BE.DEFAULT_FLAG);
        BE.setFlag("FOO", true);
        assert(BE.lookUpFlag("FOO") == true);
        BE.setFlag("FOO", false);
        assert(BE.lookUpFlag("FOO") == false);
    }

    public override void setFlag(string flagIdentifer, bool value)
    {
        flags[flagIdentifer] = value;
    }

    public override string convFlag2Str(bool result)
    {
        return result?"T":"F";
    }
    public override string runCompiledFunction(string funcIdentifer, string[] arguments)
    {
        return runCompiledDlangFunction(funcIdentifer, arguments);
    }

    public override string runCompiledDlangFunction(string funcIdentifer, string[] arguments)
    {
        import parser.functionlist;
        import std.stdio;

        auto list = instance();
        auto func = (funcIdentifer in list);
        if (func is null)
            return errorMsgFuncDoesNotExist(funcIdentifer);
        return list[funcIdentifer](arguments);
    }

}

unittest
{
    import std.stdio;

    writeln("==========================");
    BasicEvaluator BE = new BasicEvaluator();

    BE.runCompiledDlangFunction("min", ["3", "2"]);
    writeln(BE.runCompiledDlangFunction("min", ["3", "2"]));
}
