classdef Utils<handle




    properties(Constant)
        NOPROPOSAL='n/a';
    end

    methods(Static)








        function isTLSC89To99=getIsCheckTLS(model,paramName,C89Str,C99Str)
            cs=getActiveConfigSet(model);
            isTLSC89To99=false;

            if~cs.hasProp(paramName)||~cs.getPropEnabled(paramName)
                return
            end

            propStruct=configset.getParameterInfo(cs,paramName);

            if~propStruct.IsReadable
                return;
            end


            isCheckTLS=all(ismember({C89Str,C99Str},propStruct.AllowedValues));
            isTLSC89To99=isCheckTLS&&strcmp(propStruct.Value,C89Str);
        end

        function isReferenceConfigSet=checkConfigSetRef(model)
            cs=getActiveConfigSet(model);
            isReferenceConfigSet=isa(cs,'Simulink.ConfigSetRef');
        end

        getGroupsProposal(resultsScope,groups)
        specialHandlingDT=specialHandlingForResults(result,resultsScope)
        isProposable=isGroupProposable(group)
        getProposedDT(result,resultsScope,proposedDT)
    end
end


