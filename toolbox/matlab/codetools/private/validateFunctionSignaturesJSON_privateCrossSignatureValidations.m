function typeArgumentValidations=validateFunctionSignaturesJSON_privateCrossSignatureValidations()



    typeArgumentValidations={...
    @(functionInfo,log)validateInputNamesAgaintDocumentation(functionInfo,log)...
    };

end

function validateInputNamesAgaintDocumentation(functionInfo,log)

    if~functionInfo.inToolboxFolder
        return
    end

    for k=keys(functionInfo.m)
        functionName=k{1};
        if isfield(functionInfo.m(functionName),'inputArgs')
            argumentNames=getArgumentNames(functionInfo.m(functionName).inputArgs);
            messages=builtin('_assessArgumentNamesForDocumentationMatch',functionName,string(argumentNames));

            for m=1:numel(messages)
                log(functionInfo.m(functionName).functionInfo,'cannotIntegrateDoc',messages{m});
            end
        end
    end

end

function names=getArgumentNames(c)
    names={};

    for i=1:numel(c)
        if isfield(c{i},'name')




            if~isfield(c{i},'kind')||~strcmp(c{i}.kind.token,'properties')
                if isfield(c{i},'kind')&&strcmp(c{i}.kind.token,'namevalue')
                    names{end+1}=['''',c{i}.name.token,''''];%#ok<AGROW>
                else
                    names{end+1}=c{i}.name.token;%#ok<AGROW>
                end
            end
        end
    end
end
