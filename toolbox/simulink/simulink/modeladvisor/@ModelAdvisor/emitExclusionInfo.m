function exclusionContent=emitExclusionInfo(argin)





    if nargin==0
        exclusions=ModelAdvisor.ExclusionManager('get','*');
    else
        exclusionEditor=ModelAdvisor.ExclusionEditor.getInstance(bdroot(argin.MAObj.ModelName));
        exclusions=exclusionEditor.getExclusionState;
        checkIDArray={};
        checks=argin.getAllChildren;
        for i=1:length(checks)
            checkIDArray{end+1}=checks{i}.MAC;%#ok<AGROW>
        end
    end

    matchingExclusions={};
    for i=1:size(exclusions,1)
        if isAChild(exclusions{i,4},checkIDArray)
            matchingExclusions=[matchingExclusions,exclusions{i,1}];
            matchingExclusions=[matchingExclusions,exclusions{i,2}];
            matchingExclusions=[matchingExclusions,exclusions{i,3}];
            matchingExclusions=[matchingExclusions,exclusions{i,4}];
        end
    end

    if~isempty(matchingExclusions)
        infoTable=ModelAdvisor.Table(length(matchingExclusions)/4,4);
        infoTable.setColHeading(1,DAStudio.message('ModelAdvisor:engine:ExclusionRationale'));
        infoTable.setColHeading(2,DAStudio.message('ModelAdvisor:engine:ExclusionType'));
        infoTable.setColHeading(3,DAStudio.message('ModelAdvisor:engine:ExclusionValue'));
        infoTable.setColHeading(4,DAStudio.message('ModelAdvisor:engine:ExclusionCheckIDs'));
        for i=1:length(matchingExclusions)/4
            infoTable.setEntry(i,1,matchingExclusions{4*i-3});
            infoTable.setEntry(i,2,matchingExclusions{4*i-2});
            infoTable.setEntry(i,3,matchingExclusions{4*i-1});
            infoTable.setEntry(i,4,matchingExclusions{4*i});
        end
        exclusionContent=['<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',DAStudio.message('ModelAdvisor:engine:Exclusions'),'</b><br/>',infoTable.emitHTML];
    else
        exclusionContent=['<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',DAStudio.message('ModelAdvisor:engine:Exclusions'),'</b><br/><b>',DAStudio.message('ModelAdvisor:engine:NoExclusionsForGroup'),'</b>'];
    end

    return;

    newline=sprintf('\n');
    str='';
    if nargin==0

        keys=exclusions.keys;
        for i=1:length(keys)
            exclusions=exclusions(keys{i});
            str=[str,'===============',newline,DAStudio.message('ModelAdvisor:engine:ExclusionModel'),keys{i},newline,'===============',newline];
            for j=1:length(exclusions)
                str=[str,exclusions(j).view,newline];
            end
        end
    else
        str=['<center><b>',DAStudio.message('ModelAdvisor:engine:ExclusionRules'),'<b></center><br/>'];
        for j=1:length(exclusions)
            if(isAChild(exclusions(j).CheckIDs,checkIDArray))
                str=[str,exclusions(j).viewHTML('Default'),'<br/>'];
            end
        end
        for j=1:length(modelExclusions)
            if(isAChild(modelExclusions(j).CheckIDs,checkIDArray))
                str=[str,modelExclusions(j).viewHTML('model'),'<br/>'];
            end
        end
    end
end


function isachild=isAChild(CheckIDs,checkIDArray)
    isachild=false;

    if strcmp(CheckIDs,'All checks')
        isachild=true;
        return;
    end


    CheckIDs=regexprep(CheckIDs,'{','');
    CheckIDs=regexprep(CheckIDs,'}','');
    CheckIDs=strtrim(CheckIDs);
    CheckIDs=strsplit(CheckIDs,',');

    for i=1:length(checkIDArray)
        for j=1:length(CheckIDs)
            if strcmp(checkIDArray{i},CheckIDs{j})||~isempty(regexp(checkIDArray{i},CheckIDs{j}))
                isachild=true;
                break;
            end
        end
        if isachild
            break;
        end
    end
end

