function out=getField(model,fcnName,field)





    import coder.mapping.internal.*;
    noMapping=false;
    cTargetMapping=SimulinkFunctionMapping.getTargetMapping(model,fcnName);
    funcObj=SimulinkFunctionMapping.getFunctionObj(cTargetMapping,fcnName);
    if isempty(funcObj)
        noMapping=true;
    end




    lowerCaseField=lower(field);
    switch(lowerCaseField)
    case 'codeprototype'
        if noMapping
            outStruct=SimulinkFunctionMapping.getDefaultStruct(model,fcnName);
            out=outStruct.CodePrototype;
        else
            out=funcObj.MappedTo.Prototype;
        end
    otherwise
        DAStudio.error('coderdictionary:api:UnrecognizedName',field);
    end
end
