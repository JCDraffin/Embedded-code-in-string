void main()
{
	import std.format;
	import std.stdio;

	//easily generate a string in the correct format for the parser and writeln.
	string input = format(
		"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",

		"Hello, my name is @getUsername ( 0 ) . This text is here so you can have test text to run the application with.",
		"@@ is our escape character like \\ is in C based languages. Functions/Delegates are called like so @@foo().",
		"but if you need to add [@@] to your text without calling a Delegate like i did, add two @@ like so [@@@@]. Programmer@@Example.com",
		"I wrote this application to help add functionality to strings without concatenating strings with functions values.",
		"Delegate calls have their parameters converted into an array of strings, which are passed into a function from compiled code space.",
		"These delegates are scraped from the functions in functionlist.d file, and always take the form of [string foo(string[] value);] format. Here is the list of functions currently supported @funclist().",
		"",
		"The parser has no ability to parse mathematical expression, opting to pass numerical values to delegates, like so @@add(1 2 3 4 5) which gives the result: @add(1 2 3 4 5).",
		"",
		""
 );

	// string input = format(
	// 	"%s\n",

	// 	"Hello, my name is @getUsername ( 0 ).",
	// );
	import parser.tokenizer;
	Token[] tokens = lexer(input);
	// 	writeln();
	// 	writeln();
	// 	writeln();

	// foreach (i, Token key; tokens)
	// {
	// 	writeln(i, " Token: ", key);
	// }
	// 	writeln();
	// 	writeln();
	// 	writeln();

	import parser.evaluator;
	///The AbstractEvaluator lets us switch out different Evaluator objects when we need to change the logic in some way.
	AbstractEvaluator evaluator = new BasicEvaluator();
	
	import parser.node;
	RootNode treenode = new RootNode();
	treenode.parse(tokens);//this initializes the node. 

	string output = treenode.evaluate(evaluator);

	writeln(output);
}
