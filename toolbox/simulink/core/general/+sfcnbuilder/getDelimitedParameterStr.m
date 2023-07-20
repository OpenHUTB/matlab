function paramStr=getDelimitedParameterStr(params)




    NumberOfParameters=numel(params.Name);
    paramValue=params.Value;
    for index=1:NumberOfParameters
        prmDt=paramDtNameFromDt(params.DataType{index});
        if~startsWith([prmDt,'('],paramValue{index})&&...
            ~startsWith(['complex(',prmDt,'('],paramValue{index})
            if~strcmp(prmDt,'double')
                paramValue{index}=[prmDt,'(',paramValue{index},')'];
            end
        end
        if strcmp(params.Complexity{index},'COMPLEX_YES')&&...
            ~startsWith('complex(',paramValue{index})
            paramValue{index}=['complex(',paramValue{index},')'];
        end
    end
    paramStr=join(paramValue,',');
    paramStr=paramStr{1};
end

function newDt=paramDtNameFromDt(oldDt)
    if strcmp(oldDt,'real32_T')||strcmp(oldDt,'creal32_T')
        newDt='single';
    elseif strcmp(oldDt,'real_T')||strcmp(oldDt,'creal_T')
        newDt='double';
    else
        newDt=regexprep(oldDt,'c?(\w+)_T','$1');
    end
end
