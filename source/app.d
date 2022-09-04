void main()
{
	import std.format;
	import std.stdio;

	string input2 = format(
		"%s\n",
		"@sub( 1,  ,2  ,3 , 4 ,5)",);
	//easily generate a string in the correct format for the parser and writeln.
	string input = format(
		"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
		"@add( $A, $name , $B , $C , $D , $E)",
		"Hello, my name is $name. This text is here so you can have example text to run the application with.",
		"@@ is our escape character like \\ is in C based languages. Functions/Delegates are called like so @@foo().",
		"but if you need to add [@@] to your text without calling a Delegate like i did, add two @@ like so [@@@@]. Programmer@@Example.com",
		"I wrote this library to help add functionality to strings without using concatenation with functions return values.",
		"Delegate calls have their parameters converted into an array of strings, which are passed into a function from compiled code space.",
		"These delegates are scraped from the functions in functionlist.d file, and always take the form of [string foo(string[] value);] format.",
		"Here is the list of functions currently supported @funclist().",
		"",
		"The parser has no ability to parse mathematical expression, opting to pass numerical values to delegates, like so @@add(1 2 3 4 5) which gives the result: @add(1 2 3 4 5).",
		"",
		"",
		"Lets give some Example Arithmetic. A = 1, B = 2, C = 3, D = 4, E = 5, F = 1.33",
		"Just integer values $name",
		"@@add(1,2,3,4,5) = @sub(1,2,3,4,5)",

		"@@add($$A,$$B,$$C,$$D,$$E) = @add( $A, $name , $B , $C , $D , $E)",
		"@@sub($$A,$$B,$$C,$$D,$$E) = @sub( $A,$B,$C,$D,$E)",
		"@@mul($$A,$$B,$$C,$$D,$$E) = @mul( $A,$B,$C,$D,$E)",
		"@@div($$A,$$B,$$C,$$D,$$E) = @div( $A,$B,$C,$D,$E)",
		"@@div($$E,$$D,$$C,$$B,$$A) = @div( $A,$B,$C,$D,$E)",
		"\n",
		"Floating point value mixed in",
		"@@add($$A,$$B,$$C,$$D,$$E,$$F) = @add( $A,$B,$C,$D,$E,$F)",
		"@@sub($$A,$$B,$$C,$$D,$$E,$$F) = @sub( $A,$B,$C,$D,$E,$F)",
		"@@mul($$A,$$B,$$C,$$D,$$E,$$F) = @mul( $A,$B,$C,$D,$E,$F)",
		"@@div($$A,$$B,$$C,$$D,$$E,$$F) = @div( $A,$B,$C,$D,$E,$F)",
		"@@div($$E,$$D,$$C,$$B,$$A,$$F) = @div( $A,$B,$C,$D,$E,$F)",

	);

	import parser.tokenizer;

	Token[] tokens = lexer(input);

	import parser.evaluator;

	///The AbstractEvaluator lets us switch out different Evaluator objects when we need to change the logic in some way.
	AbstractEvaluator evaluator = new BasicEvaluator();
	evaluator.setVariable("name", "J. Draffin");
	evaluator.setVariable("A", "1");
	evaluator.setVariable("B", "2");
	evaluator.setVariable("C", "3");
	evaluator.setVariable("D", "4");
	evaluator.setVariable("E", "5");
	evaluator.setVariable("F", "1.33");

	import parser.node;

	RootNode treenode = new RootNode();
	treenode.parse(tokens); //this initializes the node. 

	string output = treenode.evaluate(evaluator);
	writeln(output);
}
