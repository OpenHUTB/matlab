






function[result,issue,reason]=isNameValid(name,failRegExp,reservedNames,prefix,convention)

    result=true;
    issue=[];
    reason='';

    if isempty(name)
        return;
    end


    if any(strcmp(name,reservedNames))
        result=false;
        issue=Advisor.Utils.Report.highlightIndicesInText...
        (name,1,length(name));
        reason=Advisor.Utils.Naming.getDASText(prefix,'_Issue_ReservedIdentifier');
        return;
    end


    [startIndex,endIndex]=regexp(name,failRegExp);
    if~isempty(startIndex)&&~isempty(endIndex)
        result=false;
        issue=Advisor.Utils.Report.highlightIndicesInText...
        (name,startIndex,endIndex);
        reason=Advisor.Utils.Naming.getFailingReason(prefix,name,failRegExp,convention);
        return;
    end

end


