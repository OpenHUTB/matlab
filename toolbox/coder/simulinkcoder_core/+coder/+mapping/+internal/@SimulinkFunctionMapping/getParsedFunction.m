function func=getParsedFunction(fcnPrototype)




    try
        func=coder.parser.Parser.doit(fcnPrototype);
    catch ME
        DAStudio.error('RTW:codeGen:InvalidPrototypeFormat',fcnPrototype);
    end
end
