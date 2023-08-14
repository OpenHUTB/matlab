function varList=deleteVariables(varList,toDeleteVarNames)




    if isempty(toDeleteVarNames)
        return
    end


    for varCount=numel(varList):-1:1
        if ismember(varList(varCount).Name,toDeleteVarNames)
            varList(varCount)=[];
        end
    end
end
