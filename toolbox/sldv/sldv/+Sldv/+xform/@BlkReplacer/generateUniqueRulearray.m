function fileNameList=generateUniqueRulearray(rulesListString)




    rulesList=strip_returns(rulesListString);

    ruleArray=generate_rule_array(rulesList);
    [~,I]=unique(ruleArray,'first');
    difference=setdiff(1:length(ruleArray),I);
    ruleArrayUnique=ruleArray;
    ruleArrayUnique(difference)=[];

    fileNameList=ruleArrayUnique;
end

function ruleArray=generate_rule_array(rulesList)

    ruleArray={};
    [head,remain]=strtok(rulesList,';');

    while~isempty(head)
        ruleArray{end+1}=head;%#ok<AGROW>
        [head,remain]=strtok(remain,';');%#ok<STTOK>
    end
end

function oStr=strip_returns(iStr)


    newLIdx=regexp(iStr,'\n');
    strlen=length(iStr);
    newLineLength=length(newline);
    str=[];
    startIdx=1;
    numRows=length(newLIdx);
    for i=1:length(newLIdx)
        str{i}=iStr(startIdx:newLIdx(i));%#ok<AGROW>
        startIdx=newLIdx(i)+newLineLength;
    end



    if(startIdx<strlen)
        str{length(newLIdx)+1}=iStr(startIdx:end);
        numRows=numRows+1;
    end


    oStr='';
    for i=1:numRows
        oStr=[oStr,str{i}];%#ok<AGROW>
    end

    oStr=strtrim(oStr);

    [head,tail]=strtok(oStr,' ');
    oStr='';
    while~isempty(head)
        oStr=[oStr,';',head];%#ok<AGROW>
        [head,tail]=strtok(tail,' ');%#ok<STTOK>
    end

    oStr=strrep(oStr,newline,';');
    oStr=strrep(oStr,',',';');
    oStr=strrep(oStr,'.m','');
    oStr=strrep(oStr,'.p','');
end