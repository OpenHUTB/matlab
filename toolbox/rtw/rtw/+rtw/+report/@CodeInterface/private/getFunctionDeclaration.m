

function fcnCall=getFunctionDeclaration(fcnInfo)
    argsCall=getArgsDeclaration(fcnInfo.Prototype);
    returnType=getReturnType(fcnInfo.Prototype);
    fcnName=getFcnName(fcnInfo.Prototype);
    fcnCall=[returnType,' ',fcnName,'(',argsCall,')'];

end
