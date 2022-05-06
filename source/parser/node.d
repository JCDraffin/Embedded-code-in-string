module parser.node;
import parser.tokenizer;
import parser.evaluator:AbstractEvaluator;
abstract class Node
{
    protected int nodeIndex;
    protected Token identifier;
    public Node[] parameters = [];
    abstract public int parse(Node parent, Token[] list);
    public void registerNode(Node applicant)
    {
        if (applicant is null)
            return; // would this ever be true?
        parameters ~= applicant;
    }

    

    abstract protected char[] symbol_debug();
 
    abstract public  string evaluate(AbstractEvaluator AE);
    

}

class RootNode : Node
{
    public int parse(Token[] list)
    {
        return parse(null, list);
    }

    public override int parse(Node parent, Token[] list)
    {


                import std.stdio;

        assert(list.length != 0);
        for (super.nodeIndex = 0; super.nodeIndex < list.length; nodeIndex++)
        {
            final switch (list[super.nodeIndex].tType)
            {
            case TokenType.TEXT:
            case TokenType.FLAG:
            case TokenType.VAR_:
            case TokenType.PARAM:
                Node n = new SimpleNode();
                super.nodeIndex = super.nodeIndex + n.parse(this, list[super.nodeIndex .. $]);
                break;
            case TokenType.FUNC: //nested function
                Node n = new FunctionNode();
                super.nodeIndex = super.nodeIndex + n.parse(this, list[super.nodeIndex .. $]);
                break;
            case TokenType.R_PERN: // This means we've reached the end of the function.
                //parent.registerNode(this);
                return super.nodeIndex;
            case TokenType.L_PERN:
            case TokenType.ELSE:
            case TokenType.IF_: // if any of these show up, throw an error. ELSE & IF should be supported later.
                writeln("%%ERROR%%");
                writeln(list);
                writeln(list[super.nodeIndex]);
                writeln(list[1]);

                writeln("%%ERROR%%");

                
                assert(0);
                //return 0;
            } // end switch
        } // end for

        return super.nodeIndex;
    }

    protected override char[] symbol_debug()
    {
        return ['r'];
    }

    public override string evaluate(AbstractEvaluator AE)
    {
        string text = "";
        string[] arr =[];

        ////TODO: Do i really need 2 loops?
        foreach (key; parameters)
        {
            arr ~= key.evaluate(AE);
        }

        foreach (string key; arr)
        {
            text = text ~ key;
        }
        return text;
    }

}

class ConditionalNode : Node
{

}

class SimpleNode : Node
{
    public override int parse(Node parent, Token[] list)
    {
        if (
            list.length < 1 ||
            (
                list[0].tType != TokenType.TEXT &&
                list[0].tType != TokenType.VAR_ &&
                list[0].tType != TokenType.FLAG &&
                list[0].tType != TokenType.PARAM)

            )
            return 0; //if first Node isn't text, then abort.

        identifier = list[0];
        parent.registerNode(this);
        return 0; // i dislike the fact both success and fail return the same value 
    }

    public override void registerNode(Node applicant)
    {
        assert(0);
        //return; //Text Nodes will never be able to accept branching Nodes.
    }

    protected override char[] symbol_debug()
    {
        return ['S'];
    }

    public override string evaluate(AbstractEvaluator AE)
    {
        return identifier.str;
    }
}

class FunctionNode : Node
{

    private Node[] parameterList;

    enum
    {
        FUNC_HARDCODE = 0,
        L_PREN_HARDCODE = 1
    }
    public override int parse(Node parent, Token[] list)
    {
        if (list.length < 2)
            return 0; // if list can't contain a [function identifier, l_pren and r_pern], just exit. 
        if (!(list[FUNC_HARDCODE].tType == TokenType.FUNC && list[L_PREN_HARDCODE].tType == TokenType
                .L_PERN)) // if the first two tokens don't start with the correct token, just exit.
            return 0;

        identifier = list[FUNC_HARDCODE];

        for (super.nodeIndex = 2; super.nodeIndex < list.length; nodeIndex++)
        {
            final switch (list[super.nodeIndex].tType)
            {
            case TokenType.TEXT:
            case TokenType.FLAG:
            case TokenType.VAR_:
            case TokenType.PARAM:
                Node n = new SimpleNode();
                super.nodeIndex = super.nodeIndex + n.parse(this, list[super.nodeIndex .. $]);
                break;
            case TokenType.FUNC: //nested function
                Node n = new FunctionNode();
                super.nodeIndex = super.nodeIndex + n.parse(this, list[super.nodeIndex .. $]);
                break;
            case TokenType.R_PERN: // This means we've reached the end of the function.
                parent.registerNode(this);
                return super.nodeIndex;
            case TokenType.L_PERN:
            case TokenType.ELSE:
            case TokenType.IF_: // if any of these show up, throw an error. ELSE & IF should be supported later.
                assert(0);
                //return 0;
            } // end switch
        } // end for

        return super.nodeIndex;

    }

    protected override char[] symbol_debug()
    {
        return ['F'];
    }

    public override string evaluate(AbstractEvaluator AE)
    {
        string text = "";
        string[] arr =[];
        foreach (key; parameters)
        {
            arr ~= key.evaluate(AE);
        }

        text = AE.runCompiledFunction(identifier.str ,arr);
        return text;
    }

}
