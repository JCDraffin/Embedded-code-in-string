module parser.evaluator;

public abstract class AbstractEvaluator
{
    abstract protected string errorMsg(string errorText);
    abstract protected string errorMsgFuncDoesNotExist(string funcIdentifer); // 
    abstract public string runCompiledFunction(string funcIdentifer, string[] arguments); //Function to send scripting language calls, into compiled language calls.
    abstract public string runCopmiledDlangFunction(string funcIdentifer, string[] arguments); //Should this function even exist! 

}

public class BasicEvaluator : AbstractEvaluator
{
    protected override string errorMsg(string errorText)

    {
        import std.format;

        return format!"<<%s>>"(errorText);
    }

    protected override string errorMsgFuncDoesNotExist(string funcIdentifer)
    {
        return errorMsg("No such function exist. Missing the function: " ~ funcIdentifer);
    }

    public override string runCompiledFunction(string funcIdentifer, string[] arguments)
    {
        return runCopmiledDlangFunction(funcIdentifer, arguments);
    }

    public override string runCopmiledDlangFunction(string funcIdentifer, string[] arguments)
    {
        import parser.functionlist;
        import std.stdio;

        auto list = instnace();
        auto func = (funcIdentifer in list);
        if(func is null) return errorMsgFuncDoesNotExist(funcIdentifer);
        return list[funcIdentifer](arguments);
    }

}

unittest
{
    import std.stdio;

    writeln("==========================");
    BasicEvaluator BE = new BasicEvaluator();

    BE.runCopmiledDlangFunction("min", ["3", "2"]);
    writeln(BE.runCopmiledDlangFunction("min", ["3", "2"]));
}
