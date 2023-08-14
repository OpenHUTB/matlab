function objectiveReader(obj,objectives,includeCustomization,cs)



    if nargin<4
        hasCS=false;
    else
        hasCS=true;
    end

    if nargin<2
        disp('You need to specify objectives as input argument.');
        return;
    elseif~iscell(objectives)
        obj.error=1;
        return;
    elseif strcmpi(objectives{1},'_export_To_File_')
        return;
    end

    if nargin<3
        includeCustomization=true;
    end

    if isempty(obj.ParamHash)
        disp('You need to run reader method first.');
        return;
    end

    numOfObjs=length(objectives);
    resultObjectives=cell(1,1);
    idx=0;

    for i=1:numOfObjs
        if isempty(deblank(objectives{i}))
            continue;
        end

        if hasCS
            thisObj=obj.objectiveBuilder(objectives{i},includeCustomization,cs);
        else
            thisObj=obj.objectiveBuilder(objectives{i},includeCustomization);
        end

        if thisObj.error
            continue;
        end

        idx=idx+1;
        resultObjectives{idx}=thisObj;
        resultObjectives{idx}.name=objectives{i};
        resultObjectives{idx}.count=resultObjectives{i}.len;
    end

    if idx
        obj.objectives=resultObjectives;
    end
end
