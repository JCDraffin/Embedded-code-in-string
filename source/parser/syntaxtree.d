module parser.syntaxtree;
import parser.node;
import parser.tokenizer;

const string type = "AST";

unittest
{
 
    string title = "@@ in text";
    string sample = "Hello @@ world";
    
    
    cookieCutterUnittest(title, sample);

}

unittest
{
    string title = "Dummy Code Statement";
    string sample = "Hello @min() world";

    cookieCutterUnittest(title, sample);
    //cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 5);

}

unittest
{
    string title = "Code Statement PARAMETER";
    string sample = "Hello @min(1 2 3, 4 5, 10 ) world";
    cookieCutterUnittest(title, sample);
    //cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 11);
}

 unittest
{

    string title = "Recursive Code Statement";
    string sample = "Hello @min(@min(1 2) @min( 3 4) @min(5,6) 1 2 3, 4 5, 10 ) world";

 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "Stress";
    string sample = "@TH1SNUMBER() Hello! This is just a longer bit of text to test the tokenizer. Today is @TimeNow() which is unimportant but i need to keep the text going. Your age is @max(@min(99 55) 18). One last stress @mock(@tess() kokokfoe fkokefoe @monkey(kfeoke @roger(fokokfe @baka() fkoeokfe))) damn";

 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "Simple FUNC";
    string sample = "@This1sFunc(aaaa 111111 !@@##$$%^&* @@@#@$)";

 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "Simple FLAG";
    string sample = "#isRunning";
 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "Simple VAR";
    string sample = "$waterLiter";
 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "FUNC, FLAG, VAR, ";
    string sample = "@This1sFunc( aaaa 111111 !@@##$$%^&*) @t() #isRunning $waterLiter ";
 
    cookieCutterUnittest(title, sample);
}

unittest
{

    string title = "FUNC, FLAG, VAR without spaces ";
    string sample = "@This1sFunc(aaaa 111111 !@@##$$%^&*)@t()#isRunning$waterLiter";
    string result = "";
    cookieCutterUnittest(title, sample);
}

static void cookieCutterUnittest(string title, string input, string result = "")
{
    import std.stdio : writeln, writefln;
    import parser.tokenizer: lexor;
    import parser.node;
    writefln!"\n{%s:%s}"(type,title);
    Token[] ta = lexor(input);

    foreach (i, Token key; ta)
    {
        writeln("\t", key.tType, "    \tS:\"", key.str, "\"");
    }
    RootNode root = new RootNode();
    int hasError = root.parse(null, ta);

    writefln!"%s \t Ran? %d\tlength: %d"(root,hasError,root.parmeters.length);
    if(root.parmeters.length > 2)
    writefln!"%s \t length: %d"(root.parmeters[1],root.parmeters[1].parmeters.length);
    
    if(result != "")
    {
        import parser.evaluator;
        AbstractEvaluator BE = new BasicEvaluator();
        writefln!"%s [%s]"(result, result == root.evaluate(BE) );
    }
}


