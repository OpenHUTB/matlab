function matched=arePrototypesConsistentForModelReference(fcnProto,callerProto)







    matched=true;

    if isempty(fcnProto)||isempty(callerProto)
        matched=false;
        return;
    end

    fcnObj=coder.parser.Parser.doit(fcnProto);
    callerObj=coder.parser.Parser.doit(callerProto);

    if~isequal(fcnObj.name,callerObj.name)

        matched=false;
        return;
    end

    if~isequal(length(fcnObj.returnArguments),length(callerObj.returnArguments))||...
        ~isequal(length(fcnObj.arguments),length(callerObj.arguments))

        matched=false;
        return;
    end

    for argIdx=1:length(fcnObj.arguments)
        fcnArg=fcnObj.arguments{argIdx};
        callerArg=callerObj.arguments{argIdx};
        fcnArgMappedFrom=fcnArg.mappedFrom;
        if isempty(fcnArgMappedFrom)

            fcnArgMappedFrom={fcnArg.name};
        end
        callerArgMappedFrom=callerArg.mappedFrom;
        if isempty(callerArgMappedFrom)

            callerArgMappedFrom={callerArg.name};
        end

        if~isequal(fcnArgMappedFrom,callerArgMappedFrom)||...
            ~isequal(fcnArg.qualifier,callerArg.qualifier)||...
            ~isequal(fcnArg.passBy,callerArg.passBy)


            matched=false;
            return;
        end
    end

    for argIdx=1:length(fcnObj.returnArguments)
        fcnArg=fcnObj.returnArguments{argIdx};
        callerArg=callerObj.returnArguments{argIdx};
        if~isequal(fcnArg.mappedFrom,callerArg.mappedFrom)||...
            ~isequal(fcnArg.qualifier,callerArg.qualifier)||...
            ~isequal(fcnArg.passBy,callerArg.passBy)


            matched=false;
            return;
        end
    end
end
