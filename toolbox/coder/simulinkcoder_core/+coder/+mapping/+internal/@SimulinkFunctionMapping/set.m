function set(model,fcnName,varargin)





    import coder.mapping.internal.*;

    newCodePrototype='';
    for i=1:2:length(varargin)
        name=varargin{i};
        value=varargin{i+1};
        if(~ischar(name))
            DAStudio.error('coderdictionary:api:NameValuePairNeedsStringForName',name);
        end


        lowerCaseName=lower(name);
        switch lowerCaseName
        case 'codeprototype'
            if~ischar(value)
                DAStudio.error('coderdictionary:api:NameValuePairNeedsStringForValue',name);
            end
            newCodePrototype=value;
        otherwise
            DAStudio.error('coderdictionary:api:UnrecognizedName',name);
        end
    end

    SimulinkFunctionMapping.validatePublicFunction(model,...
    fcnName);


    coderDictMapping=SimulinkFunctionMapping.getOrCreateCoderDictMapping(model);
    cache=SimulinkFunctionMapping.get(model,fcnName);


    if isempty(newCodePrototype)
        newCodePrototype=cache.CodePrototype;
    end



    func=SimulinkFunctionMapping.getParsedFunction(newCodePrototype);
    SimulinkFunctionMapping.validateUseOfRenaming(model,func,fcnName);

    funcObj=[];
    funcObj=SimulinkFunctionMapping.setPrototype(model,fcnName,coderDictMapping,newCodePrototype,funcObj);
    if~isempty(funcObj)

        coderDictMapping.addSimulinkFunctionMapping(fcnName,funcObj);
    end
end
