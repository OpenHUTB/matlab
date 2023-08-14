function result=objectiveBuilder(obj,objective,includeCustomization,cs)











    if nargin<4
        hasCS=false;
    else
        hasCS=true;
    end

    if nargin<3
        includeCustomization=false;
    end

    if isempty(obj.ParamHash)
        disp('You need to run reader method first.');
        return;
    end

    fixedCheck=coder.advisor.internal.CGOFixedCheck;
    fixedCheckID=fixedCheck.checkID;
    checkHash=fixedCheck.checkHash;
    doCustomization=true;

    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')<=0
        doCustomization=false;
    end

    if doCustomization
        if includeCustomization
            cm=DAStudio.CustomizationManager;
            customizedCheck=cm.ObjectiveCustomizer.additionalCheck;
            for i=1:length(customizedCheck)
                checkHash.put(customizedCheck{i},length(fixedCheckID)+i);
            end
        end
    end


    factoryObjective={'RAM efficiency',...
    'ROM efficiency',...
    'Execution efficiency',...
    'Traceability',...
    'Safety precaution',...
    'Debugging',...
    'MISRA C:2012 guidelines',...
    'Polyspace'};

    if~any(strcmp(objective,factoryObjective))

        if doCustomization&&includeCustomization
            customizedObjLen=length(cm.ObjectiveCustomizer.objective);
        else
            customizedObjLen=0;
        end

        for i=1:customizedObjLen
            if strcmp(cm.ObjectiveCustomizer.objective{i}.objectiveID,objective)
                thisObj=cm.ObjectiveCustomizer.objective{i};


                params=cell(length(thisObj.parameters),0);
                pIdx=0;
                for j=1:length(thisObj.parameters)
                    if isempty(thisObj.parameters{j})
                        continue;
                    end

                    paramName=thisObj.parameters{j}.name;
                    id=[];
                    if~isempty(obj.ParamHash.get(paramName))
                        id=obj.ParamHash.get(paramName);
                    end

                    if isempty(id)
                        fprintf('"%s" is not included in the rtw.codegenObjectives.ConfigSetProp object.\n',paramName);
                        return;
                    end

                    pIdx=pIdx+1;
                    params{pIdx}.id=id;
                    params{pIdx}.name=deblank(paramName);
                    params{pIdx}.setting=thisObj.parameters{j}.value;
                    params{pIdx}.target='';
                    params{pIdx}.setting2='';
                    params{pIdx}.target2='';
                end


                checklist=cell(length(thisObj.checks),0);
                cIdx=0;

                checkLen=length(fixedCheckID);
                if includeCustomization
                    checkLen=checkLen+length(customizedCheck);
                end

                for j=1:checkLen
                    cIdx=cIdx+1;
                    checklist{cIdx}.id=j;
                    checklist{cIdx}.value=0;
                end

                for j=1:length(thisObj.checks)
                    if isempty(thisObj.checks{j})
                        continue;
                    end

                    index=checkHash.get(thisObj.checks{j}.MAC);
                    if~isempty(index)
                        checklist{index}.value=thisObj.checks{j}.setting;
                    end
                end

                result.params=params;
                result.checklist=checklist;
                result.len=pIdx;
                result.checklen=cIdx;
                result.file=[];
                result.error=0;

                return;
            end
        end

        result.error=6;

        return;
    end


    if ischar(objective)
        filename=objective;
        r=strfind(objective,'Objective_');
        if isempty(r)||r~=1
            switch objective
            case 'RAM efficiency'
                objective='Efficiency_ram';
            case 'ROM efficiency'
                objective='Efficiency_rom';
            case 'Execution efficiency'
                objective='Efficiency_speed';
            case 'Safety precaution'
                objective='Safety precaution';
            case 'MISRA C:2012 guidelines'
                objective='MISRA_C';
            case 'Polyspace'
                objective='polyspace';
            end

            filename=['objective_',lower(strrep(objective,' ',''))];
        end
    else
        result.error=5;
        result.name=objective;
        return;
    end

    result=eval(['obj.',filename]);

    if hasCS
        if strcmpi(get_param(cs,'IsERTTarget'),'on')==1
            params=result.params;
        else
            params=[];
            paramsERT=result.params;
            for i=1:length(paramsERT)
                if strcmp(paramsERT{i}.target,'grt')==1
                    params{end+1}=paramsERT{i};%#ok
                end
            end
        end

        result.len=length(params);
    else
        params=result.params;
    end

    for i=1:length(params)
        resultId=obj.ParamHash.get(params{i}.name);
        if isempty(resultId)
            fprintf('"%s" is not included in the rtw.codegenObjectives.ConfigSetProp object.\n',params{i}.name);
            return;
        end

        params{i}.id=resultId;
    end

    result.params=params;


