function outFcnCSList=validateCustomCodeDeterministicFunctionsString(inFcnCSList)


    outFcnCSList=inFcnCSList;
    if isempty(inFcnCSList)
        return;
    end


    cellFcns=strsplit(inFcnCSList,',');
    cellFcns=unique(strtrim(cellFcns));
    cellFcns=cellFcns(~cellfun('isempty',cellFcns));

    checkInvalidChars(cellFcns);


    outFcnCSList=sprintf('%s,',cellFcns{:});
    outFcnCSList(end)=[];

end

function checkInvalidChars(allFcnNames)


    fcnsLeadUnderScoreRem=regexprep(allFcnNames,'^_+','');


    invalidCharLogIndx=cellfun(@(x)(~(isvarname(x)||isempty(x))),fcnsLeadUnderScoreRem);
    if any(invalidCharLogIndx)
        invalidCharNames=unique(allFcnNames(invalidCharLogIndx));
        namesToReport=sprintf('''%s'', ',invalidCharNames{:});
        namesToReport(end-1:end)=[];
        e=MException(message('Simulink:CustomCode:DeterministicFunctionsInvalidCharacterNames',namesToReport));
        e.throw();
    end
end