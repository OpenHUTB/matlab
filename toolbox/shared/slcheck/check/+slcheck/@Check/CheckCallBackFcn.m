function CheckCallBackFcn(this,system,checkObj)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    FollowLinks=mdladvObj.getInputParameterByName('Follow links');
    if isempty(FollowLinks)
        FL='on';
    else
        FL=FollowLinks.Value;
    end

    LookUnderMasks=mdladvObj.getInputParameterByName('Look under masks');
    if isempty(LookUnderMasks)
        LUM='on';
    else
        LUM=LookUnderMasks.Value;
    end

    entities=this.relevantEntities(system,FL,LUM);
    entities=mdladvObj.filterResultWithExclusion(entities);

    numlevels=numel(this.SubChecksCfg);

    ActiveSubChecks=cell(1,numlevels);

    for j=1:numlevels
        if strcmp(this.SubChecksCfg(j).Type,'Normal')
            SO=slcheck.getSubCheckObject(this.SubChecksCfg(j).subcheck);
            SO.MessageCatalogPrefix=this.CheckCatalogPrefix;
            if numlevels>1&&~isSubCheckSelected(getIPNameFromSubcheck(SO),mdladvObj)
                continue;
            end
        elseif strcmp(this.SubChecksCfg(j).Type,'Group')


            groupName=this.SubChecksCfg(j).GroupName;
            iParam=mdladvObj.getInputParameterByName(groupName);

            subcheckIndex=iParam.Value;

            if numlevels~=1&&subcheckIndex==0
                continue;
            end

            SO=slcheck.getSubCheckObject(this.SubChecksCfg(j).subcheck(subcheckIndex+(numlevels==1)));
            SO.MessageCatalogPrefix=this.CheckCatalogPrefix;

        else
            error('Invalid Type setting on Subcheck Config');
        end
        SO.setCheckId(checkObj.ID);
        setInputParams(SO,inputParams);
        ActiveSubChecks{j}=SO;
    end


    results=[];
    for i=1:length(entities)
        if isempty(entities{i})
            continue;
        end

        for j=1:numel(ActiveSubChecks)
            if~isempty(ActiveSubChecks{j})
                SO=ActiveSubChecks{j};
                if isa(SO,'slcheck.SFEditTimeCheck')
                    SO.setTaskID(checkObj.TaskID)
                end
                SO.setEntity(entities{i});
                SO.clearResultCache();
                SO.run();
                results=[results;SO.getResult()];%#ok<AGROW>            
            end
        end
    end

    this.gatherAndSetResults(results,checkObj,mdladvObj);

end

function name=getIPNameFromSubcheck(Subcheck)
    name='';
    if~isempty(Subcheck.ID)
        name=[name,Subcheck.ID,': '];
    end
    name=[name,Subcheck.getDescription()];
end

function isSelected=isSubCheckSelected(Name,mdladvObj)
    isSelected=false;
    iParam=mdladvObj.getInputParameterByName(Name);
    if isempty(iParam)

        params=mdladvObj.getInputParameters;
        for paramsIdx=1:numel(params)
            if~strcmp(params{paramsIdx}.Type,'RadioButton')
                continue;
            end






            entries=params{paramsIdx}.Entries;
            if strcmp(entries{params{paramsIdx}.Value+1},Name)
                isSelected=true;
                return;
            end
        end
    else
        isSelected=iParam.Value;
    end
end

function setInputParams(SO,Iparams)
    for i=1:numel(Iparams)
        if iscell(Iparams{i}.Value)
            continue
        end
        SO.setInputParam(Iparams{i}.Name,num2str(Iparams{i}.Value));
    end
end

