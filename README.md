This application(library?) is able to take strings, and find function calls. It's a non-Turing-complete parsed language.
The goal of this project is to provide a solution in cases where printed text is slightly changed based on a conditional.
i.e.
``` 
void example(ubyte timeInHours)
{
  if(timeInHours < 12)
    writeln("Good morning");
  else
    writeln("Good afternoon);
}
```

Theoretically, we can reduce that to 1 string which allows us to simplify the compiled code, add functionality without recompilation, and store strings in a external text file (XML, JSON, YAML) 

=====
Compile:
```git clone git@github.com:JCDraffin/Embedded-code-in-string.git
cd Embedded-code-in-string
dub build
``` 

=====
TODO:
conditional logic 
flags 
variable 
