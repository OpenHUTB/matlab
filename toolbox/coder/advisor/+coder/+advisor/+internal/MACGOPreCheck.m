


function result=MACGOPreCheck(checkLen,objectivePriorities,cs)



    if nargin<3
        hasCS=false;
    else
        hasCS=true;
    end

    checkid=cell(checkLen,1);

    for i=1:checkLen
        checkid{i}=['com.mathworks.cgo.',num2str(i)];
    end

    checkMap=containers.Map('KeyType','int32','ValueType','char');

    if isempty(objectivePriorities)||isempty(objectivePriorities{1})
        checkMap(1)=checkid{1};
        result=checkMap;
        return;
    end

    includeCustomization=true;
    cspObj=rtw.codegenObjectives.ConfigSetProp;
    cspObj.reader();
    if hasCS
        cspObj.objectiveReader(objectivePriorities,includeCustomization,cs);
    else
        cspObj.objectiveReader(objectivePriorities,includeCustomization);
    end

    len_op=length(cspObj.objectives);
    checklist=cell(len_op,1);

    cm=DAStudio.CustomizationManager;
    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
        extraChkLen=length(cm.ObjectiveCustomizer.additionalCheck);
    else
        extraChkLen=0;
    end

    skip=zeros(len_op,1);

    for i=1:len_op
        obj=cspObj.objectives{i};

        if~isempty(obj)
            checklist{i}=obj.checklist;

            if length(checklist{i})~=checkLen
                for j=1:extraChkLen
                    checklist{i}{obj.checklen+j}.id=obj.checklen+j;
                    checklist{i}{obj.checklen+j}.value=0;
                end
            end

            if checkLen<obj.checklen
                checkLen=obj.checklen;
            end
        else
            skip(i)=1;
        end
    end

    for i=1:checkLen
        for j=1:len_op
            if skip(j)==0
                if i<=length(checklist{j})&&~isempty(checklist{j}{i})
                    if checklist{j}{i}.value==-1

                        break;
                    elseif checklist{j}{i}.value==1

                        if i<=length(checkid)
                            checkMap(i)=checkid{i};
                        end
                        break;
                    end
                end
            end
        end
    end

    result=checkMap;
end































