module parser.tokenizer;

///TokenType will be used as an identifier to figure out logic, later. 
enum TokenType
{
    TEXT = 0,
    FUNC = 1,
    PARAM = 2,
    L_PERN = 3,
    R_PERN = 4,
    FLAG = 5,
    VAR_ = 6,
    IF_ = 7,
    ELSE = 8,
}

///Token is a convenient storage type for moving around essential text and token identifier for future logic. 
struct Token
{
    import std.conv;

    TokenType tType;
    string str;

    this(TokenType tType, string str)
    {
        this.tType = tType;
        this.str = str;
    }

    this(TokenType tType, char[] str)
    {
        this.tType = tType;
        this.str = to!string(str);
    }

}

abstract class AbstractScanState
{
    Data data;
    private Token[] tokens3;
    protected TokenizerStateMachine parentStateMachine;
    void ignToken()
    {
        data.buffer = [];
    }

    public Token[] sendThenScrub()
    {
        Token[] result = tokens3;
        tokens3.length = 0;
        return result;
    }

    this(Data data, TokenizerStateMachine parentStateMachine)
    {
        //this.tokens3 = tokens;
        this.data = data;
        this.parentStateMachine = parentStateMachine;
    }
    //Method to add a token, then clean up the buffer.
    void addToken(TokenType ttype)
    {
        data.tokens ~= Token(ttype, data.buffer);
        ignToken();

    }
    //Helper delegates. Just makes things cleaner.

    //Make a token for a complex identifier, cleaner. 
    void make(TokenType ttype)
    {
        ubyte debug_token_type = 0;
        debug_token_type = cast(ubyte) ttype;

        bool isValidName = true;

        // ulong tempIndex = lexerIndex +1;
        ulong tempIndex = data.scanNextWord(data.lexerIndex + 1);
        if (tempIndex == ulong.max)
            return;
        ///
        while (tempIndex < data.text.length && isValidName)
        {
            char focusChar = data.focusChar(tempIndex);
            switch (focusChar)
            {

            case '0': .. case '9':
            case 'A': .. case 'Z':
            case 'a': .. case 'z': //case '0': .. case 'z':

                data.buffer ~= focusChar;
                tempIndex++;
                break;
            default:

                isValidName = false;
                break;
            }
        }

        tempIndex--;
        data.lexerIndex = tempIndex;

        data.tokens ~= Token(ttype, data.buffer);
        ignToken();

        //addSpecialToken();
    }

    abstract Token[] scanChar();
}

class TextScanState : AbstractScanState
{
    this(Data data, TokenizerStateMachine parentStateMachine)
    {
        super(data, parentStateMachine);
    }

    override Token[] scanChar()
    {

        //Helper delegates to make complexIdentifiers cleaner.
        //auto makeVar = () => make(addVar => (addToken(TokenType.VAR_, "DELETEME")));
        //auto makeFlag = () => make(addFlag => (addToken(TokenType.FLAG, "DELETEME")));
        //auto makeFunc = () => make(addFunc => (addToken(TokenType.FUNC, "DELETEME")));
        switch (data.focusChar)
        {
        case '@':
            if (data.checkPeak(data.lexerIndex + 1, '@'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else if (data.checkPeak(data.lexerIndex + 1, '#'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else if (data.checkPeak(data.lexerIndex + 1, '$'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else
            {

                addToken(TokenType.TEXT);
                data.buffer ~= data.focusChar;
                ignToken();
                make(TokenType.FUNC);
                // lexerState = CODE_SINGLE_STATE;
                parentStateMachine.switchState(false);
            }
            break;
        case '#':

            if (data.checkPeak(data.lexerIndex + 1, '#'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else
            {
                addToken(TokenType.TEXT);
                make(TokenType.FLAG);
            }

            break;
        case '$':

            if (data.checkPeak(data.lexerIndex + 1, '$'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else
            {

                addToken(TokenType.TEXT);
                make(TokenType.VAR_);
            }
            break;
        default:
            data.buffer ~= data.focusChar;
            break;
        }
        return sendThenScrub;
    }
}

class CodeScanState : AbstractScanState
{
    this(Data data, TokenizerStateMachine parentStateMachine)
    {
        super(data, parentStateMachine);
    }

    override Token[] scanChar()
    {

        //tokens3 ~= Token(TokenType.IF_, "Debug");
        switch (data.focusChar)
        {
            // TEXT, S_STATEMENT, PARAM, L_PERN, R_PREN,  BLOCK
        case '(':

            data.buffer ~= data.focusChar;
            addToken(TokenType.L_PERN);
            break;

        case ')':

            if (data.buffer.length != 0)
            {
                addToken(TokenType.PARAM);
            }
            data.buffer ~= data.focusChar;
            addToken(TokenType.R_PERN);

            //count the Rpern vs Lpern
            int l = 0;
            int r = 0;
            foreach (Token key; tokens3)
            {
                if (key.tType == TokenType.R_PERN)
                    r++;
                else if (key.tType == TokenType.L_PERN)
                    l++;
            }
            if (l == r)
            {
                // lexerState = TEXT_STATE;
                parentStateMachine.switchState(true);

            }

            break;
        case ',':
            if (data.buffer.length == 0)
                break;
            addToken(TokenType.PARAM);

            break;
        case '#':
            if (data.checkPeak(data.lexerIndex + 1, '#'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else
            {
                data.buffer ~= data.focusChar;
                ignToken();
                make(TokenType.FLAG);
            }

            break;
        case '$':
            if (data.checkPeak(data.lexerIndex + 1, '$'))
            {
                data.lexerIndex++;
                data.buffer ~= data.focusChar;
            }
            else
            {
                addToken(TokenType.TEXT);
                make(TokenType.VAR_);
            }

            break;
        case '@':
            if (data.checkPeak(data.lexerIndex + 1, '@') || data.checkPeak(data.lexerIndex + 1, '#') || data.checkPeak(
                    data.lexerIndex + 1, '$'))
            {
                data.lexerIndex++; //move the index head directly to the right.
                data.buffer ~= data.text[data.lexerIndex]; //We don't use focusChar because the character we care about is special character directly to it's right.  
            }
            else
            {

                data.buffer ~= data.focusChar;
                ignToken();
                make(TokenType.FUNC);
            }
            break;
        default:

            if (data.focusChar != ' ')
                data.buffer ~= data.focusChar;
            char charbuf = data.peakAhead(data.lexerIndex + 1);

            if (charbuf == ' ' || charbuf == '\t' || charbuf == '\n' || charbuf == '\r')
            {
                data.lexerIndex++;
                addToken(TokenType.PARAM);
                //if (tokens.length > 0 && tokens[$].tType == TokenType.PARAM ||tokens[$].tType == TokenType.R_PERN )    addToken(TokenType.PARAM);   
            }

            else if (charbuf == ')')
            {

                addToken(TokenType.PARAM);
            }
            //else if (tokens[$ - 1].tType == TokenType.S_STATEMENT)
            // {
            // if (!isAlphaNum(peakAhead()))
            // addFunc();
            // }
        }
        return sendThenScrub;
    }
}

class DebugScanState : AbstractScanState
{

    this(Data data, TokenizerStateMachine tsm)
    {
        super(data, tsm);
    }

    override Token[] scanChar()
    {
        data.buffer ~= data.focusChar;
        addToken(TokenType.TEXT);
        return tokens3;
    }
}

class TokenizerStateMachine
{

    private AbstractScanState currentState;
    public TextScanState textScanner;
    public CodeScanState codeScanner;

    public this(Data data)
    {
        textScanner = new TextScanState(data, this);
        codeScanner = new CodeScanState(data, this);

        currentState = textScanner;
    }

    public Token[] scanChar()
    {
        return currentState.scanChar();
    }

    public void switchState(bool isUsingTextScanner)
    {

        if (isUsingTextScanner)
        {
            currentState = textScanner;
        }
        else
        {
            currentState = codeScanner;
        }

    }

}

private class Data
{
    ///In use cases where we have to return a primitive char value, but there is no value to return.
    const NEG_ACK = cast(char) 21;
    byte lexerState = 0;
    ulong lexerIndex = 0;
    char[] buffer = [];

    string text;

    Token[] tokens;

    public this(string text)
    {
        this.text = text;
        buffer = [];

        lexerState = 0;
        lexerIndex = 0;
    }

    public char focusChar()
    {
        return focusChar(lexerIndex);
    }

    public char focusChar(ulong index)
    {
        return lexerIndex < text.length ? text[index] : text[$ - 1];
    }

    public bool checkPeak(char testsubject)
    {
        return checkPeak(lexerIndex + 1, testsubject);
    }

    public bool checkPeak(ulong index, char testSubject)
    {

        return hasPeak(index) && testSubject == peakAhead(index);
    }

    public bool hasPeak(ulong index)
    {
        return text.length > index;
    }

    public char peakAhead(ulong index)
    {
        if (text.length <= index)
            return NEG_ACK;
        return text[index];
    }

    public ulong scanNextWord(ulong startLocation)
    {

        while (startLocation < text.length)
        {
            char charbuffer = text[startLocation];
            switch (charbuffer)
            {
            case ' ':
            case '\t':
            case '\n':
            case '\r':
                startLocation++;
                break;
            default:
                return startLocation;
            }
        }

        return ulong.max;
    }

    public char peakAhead()
    {
        return peakAhead(lexerIndex + 1);
    }
}

public Token[] lexer(string text)
{

    auto data = new Data(text);

    //Method to add a token, then clean up the buffer.
    void addToken(TokenType ttype)
    {
        data.tokens ~= Token(ttype, data.buffer);
        data.buffer = [];
    }
    //Helper delegates. Just makes things cleaner.
    auto addText = () => addToken(TokenType.TEXT);
    auto addVar = () => addToken(TokenType.VAR_);
    auto addFlag = () => addToken(TokenType.FLAG);
    auto addFunc = () => addToken(TokenType.FUNC);
    auto addParm = () => addToken(TokenType.PARAM);

    void make(void delegate() addSpecialToken)
    {
        bool isValidName = true;

        // ulong tempIndex = lexerIndex +1;
        ulong tempIndex = data.scanNextWord(data.lexerIndex + 1);
        if (tempIndex == ulong.max)
            return;
        ///
        while (tempIndex < data.text.length && isValidName)
        {
            char focusChar = data.focusChar;
            switch (focusChar)
            {

            case '0': .. case '9':
            case 'A': .. case 'Z':
            case 'a': .. case 'z': //case '0': .. case 'z':

                data.buffer ~= focusChar;
                tempIndex++;
                break;
            default:

                isValidName = false;
                break;
            }
        }

        tempIndex--;
        data.lexerIndex = tempIndex;

        addSpecialToken();
    }

    auto stateMachine = new TokenizerStateMachine(data);
    // auto textLex = new TextScanState(tokens);
    // auto codeLex = new CodeScanState(tokens);
    //Incase you want to clean up the token buffers, but don't want to create a token.
    void ignToken()
    {
        data.buffer = [];
    }

    string bufferDebug;
    for (; data.lexerIndex < data.text.length; data.lexerIndex++)
    {

        ulong size = data.tokens.length;

        Token[] sample = data.tokens.dup;

        stateMachine.scanChar();

        // this is a HACK!

        // if (lexerState == TEXT_STATE)
        //     textLex.lex(focusChar);

        // else if (lexerState == CODE_SINGLE_STATE)
        //     codeLex.lex(focusChar);

        // else if (lexerState == TEXT_STATE) switch (focusChar)
        // {
        // default:
        //     assert(0);
        // }
        // else
        //     assert(0);

    }

    const TEXT_STATE = 0;
    const CODE_SINGLE_STATE = 1;
    const CODE_BLOCK_STATE = 2;

    switch (data.lexerState)
    {
    case TEXT_STATE:
        addText();
        break;
    case CODE_SINGLE_STATE:
        //addCode();
        break;
    case CODE_BLOCK_STATE:
        //addBlock();
        break;
    default:
        assert(0);

    }
    return data.tokens;
}

// bool isNumeric(char sample)
// {
//     return false;
// }

// bool isAlphabet(char sample)
// {

//     return false;
// }

/++ 
 * 
 +/
// pure nothrow @nogc @safe bool isAlpha(dchar c)
// {
//     import std.ascii : isAlpha;

//     return isAlpha(c);
// }

// pure nothrow @nogc @safe bool isDigit(dchar c)
// {
//     import std.ascii : isDigit;

//     return isDigit(c);
// }

// pure nothrow @nogc @safe bool isAlphaNum(dchar c)
// {
//     import std.ascii : isAlphaNum;

//     return isAlphaNum(c);
// }
/*************************************************
 *Everything after this point in Unittest related*
 *************************************************/

///method to quickly make new unit test. It should only be compile time, but i need to check documentation.  
static void cookieCutterUnittest(string title, string input, string[] stringSample, TokenType[] tokenSample, int tokenLength = -1)
{
    if (input !is null)
        return;
    import std.stdio : writeln, writefln;

    ///returns true when the generated token array is long enough, or when skip value (-1) is given  
    bool isRightLength(ulong sample)
    {
        return tokenLength < 0 || sample == tokenLength;
    }

    writefln!"\n{%s}"(title);
    Token[] ta = lexer(input);

    writeln("Compare both sample array's length: ", tokenSample.length, " ", stringSample.length, " Expected length is : ", tokenLength);
    assert(tokenSample.length == stringSample.length && isRightLength(stringSample.length));

    foreach (i, Token key; ta)
    {
        writeln("\t", key.tType, "    \tS:\"", key.str, "\"");
        // writeln(key, "\t\tT:", key.tType, "  \tS:\"", key.str, "\"");
        assert(tokenSample[i] == key.tType);
        if (stringSample[i] != key.str)
            writeln(stringSample[i], stringSample[i].length, "\t", key.str, key.str.length);
        assert(stringSample[i] == key.str);
    }
    assert(isRightLength(ta.length));
    writeln("{END}");

}

unittest
{
    string title = "Basic text";
    string sample = "Hello world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [TEXT];
        stringCheck = ["Hello world"];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 1);

}

unittest
{
    string title = "@@ in text";
    string sample = "Hello @@ world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT
        ];
        stringCheck = [
            "Hello @ world"
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 1);

}

unittest
{
    string title = "Dummy Code Statement";
    string sample = "Hello @min() world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [TEXT, FUNC, L_PERN, R_PERN, TEXT];
        stringCheck = ["Hello ", "min", "(", ")", " world"];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 5);

}

unittest
{
    string title = "Code Statement PARAMETER";
    string sample = "Hello @min(1 2 3, 4 5, 10 ) world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, PARAM, PARAM, PARAM, PARAM, PARAM,
            PARAM, R_PERN, TEXT
        ];
        stringCheck = [
            "Hello ", "min", "(", "1", "2", "3", "4", "5", "10", ")",
            " world"
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 11);
}

unittest
{
    string title = "Code Statement PARAMETER, w/ commas";
    string sample = "Hello @min(,1, 2, 3,4, 5,10,) world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, PARAM, PARAM, PARAM, PARAM, PARAM,
            PARAM, R_PERN, TEXT
        ];
        stringCheck = [
            "Hello ", "min", "(", "1", "2", "3", "4", "5", "10", ")",
            " world"
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 11);
}

unittest
{

    string title = "Recursive Code Statement";
    string sample = "Hello @min(@min(1 2) @min( 3 4) @min(5,6) 1 2 3, 4 5, 10 ) world";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT,
            FUNC, L_PERN,
            FUNC, L_PERN, PARAM, PARAM, R_PERN,
            FUNC, L_PERN, PARAM, PARAM, R_PERN,
            FUNC, L_PERN, PARAM, PARAM, R_PERN,
            PARAM, PARAM, PARAM, PARAM, PARAM, PARAM,
            R_PERN, TEXT
        ];
        stringCheck = [
            "Hello ",
            "min", "(",
            "min", "(", "1", "2", ")",
            "min", "(", "3", "4", ")",
            "min", "(", "5", "6", ")", "1", "2", "3", "4", "5", "10",
            ")", " world"
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 26);
}

unittest
{

    string title = "Stress";
    string sample = "@TH1SNUMBER() Hello! This is just a longer bit of text to test the tokenizer. Today is @TimeNow() which is unimportant but i need to keep the text going. Your age is @max(@min(99 55) 18). One last stress @mock(@tess() kokokfoe fkokefoe @monkey(kfeoke @roger(fokokfe @baka() fkoeokfe))) damn";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, R_PERN,
            TEXT,
            FUNC, L_PERN, R_PERN,
            TEXT,
            FUNC, L_PERN, FUNC, L_PERN, PARAM, PARAM, R_PERN, PARAM, R_PERN,
            TEXT,
            FUNC, L_PERN,
            FUNC, L_PERN, R_PERN,
            PARAM, PARAM, FUNC, L_PERN, PARAM, FUNC, L_PERN, PARAM, FUNC, L_PERN,
            R_PERN, PARAM,

            R_PERN, R_PERN,
            R_PERN, TEXT
        ];
        stringCheck = [
            "", "TH1SNUMBER", "(", ")",
            " Hello! This is just a longer bit of text to test the tokenizer. Today is ",
            "TimeNow", "(", ")",
            " which is unimportant but i need to keep the text going. Your age is ",
            "max", "(", "min", "(", "99", "55", ")", "18", ")",
            ". One last stress ",
            "mock", "(",
            "tess", "(", ")",
            "kokokfoe", "fkokefoe", "monkey", "(", "kfeoke", "roger", "(",
            "fokokfe", "baka", "(", ")", "fkoeokfe",
            ")", ")",
            ")", " damn"
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 40);
}

unittest
{

    string title = "Simple FUNC";
    string sample = "@This1sFunc(aaaa 111111 !@@##$$%^&* @@@#@$)";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, PARAM, PARAM, PARAM, PARAM, R_PERN, TEXT,

        ];
        stringCheck = [
            "", "This1sFunc", "(", "aaaa", "111111", "!@#$%^&*", "@#$", ")", "",

        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 9);
}

unittest
{

    string title = "Simple FLAG";
    string sample = "#isRunning";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FLAG, TEXT,
        ];
        stringCheck = [
            "", "isRunning", "",
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 3);
}

unittest
{

    string title = "Simple VAR";
    string sample = "$waterLiter";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, VAR_, TEXT
        ];
        stringCheck = [
            "", "waterLiter", "",
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 3);
}

unittest
{

    string title = "FUNC, FLAG, VAR, ";
    string sample = "@This1sFunc( aaaa 111111 !@@##$$%^&*) @t() #isRunning $waterLiter ";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, PARAM, PARAM, PARAM, R_PERN, TEXT,
            FUNC, L_PERN, R_PERN, TEXT, FLAG, TEXT, VAR_, TEXT
        ];
        stringCheck = [
            "", "This1sFunc", "(", "aaaa", "111111", "!@#$%^&*", ")", " ",
            "t", "(", ")", " ", "isRunning", " ", "waterLiter", " ",
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 16);
}

unittest
{

    string title = "FUNC, FLAG, VAR without spaces ";
    string sample = "@This1sFunc(aaaa 111111 !@@##$$%^&*)@t()#isRunning$waterLiter";

    TokenType[] tokenCheck;
    string[] stringCheck;

    //declare the variables used in the *with_statement* before, so you can call them outside the *with_statement*
    with (TokenType)
    {
        tokenCheck = [
            TEXT, FUNC, L_PERN, PARAM, PARAM, PARAM, R_PERN, TEXT,
            FUNC, L_PERN, R_PERN, TEXT, FLAG, TEXT, VAR_, TEXT
        ];
        stringCheck = [
            "", "This1sFunc", "(", "aaaa", "111111", "!@#$%^&*", ")", "",
            "t", "(", ")", "", "isRunning", "", "waterLiter", "",
        ];
    }
    cookieCutterUnittest(title, sample, stringCheck, tokenCheck, 16);
}
