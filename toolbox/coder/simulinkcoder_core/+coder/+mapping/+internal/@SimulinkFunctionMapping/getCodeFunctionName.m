function out=getCodeFunctionName(fcnPrototype)




    func=coder.mapping.internal.SimulinkFunctionMapping.getParsedFunction(fcnPrototype);
    out=func.name;
end
