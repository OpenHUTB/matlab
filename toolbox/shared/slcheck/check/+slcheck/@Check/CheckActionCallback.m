function result=CheckActionCallback(this,~)
    result=ModelAdvisor.Paragraph;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);

    checkObj=mdladvObj.getCheckObj(this.ID);
    FailingObjs=checkObj.ResultDetails;

    numlevels=numel(this.SubChecksCfg);

    isFixed=false;

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
        if~ismethod(SO,'fixit')
            fObjs=FailingObjs(arrayfun(@(x)strcmp(x.CheckAlgoID,SO.ID),FailingObjs));
            ft=ModelAdvisor.FormatTemplate('ListTemplate');
            ft.setSubBar(true);
            ft.setInformation(DAStudio.message('Advisor:engine:ActionNotPossible'));
            ft.setListObj(arrayfun(@(x)x.Data,fObjs,'UniformOutput',false));
            result.addItem(ft.emitContent);
        else
            SO.setCheckId(checkObj.ID);

            lData={};
            for i=1:length(FailingObjs)
                if~strcmp(FailingObjs(i).CheckAlgoID,SO.ID)
                    continue;
                end

                if isempty(ModelAdvisor.ResultDetail.getData(FailingObjs(i)))
                    continue;
                end

                SO.setEntity(ModelAdvisor.ResultDetail.getData(FailingObjs(i)));
                status=SO.fixit();
                if status
                    lData{end+1}=ModelAdvisor.ResultDetail.getData(FailingObjs(i));
                    isFixed=isFixed||true;
                end
            end

            if~isempty(lData)
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                ft.setSubBar(true);
                ft.setInformation(DAStudio.message([this.CheckCatalogPrefix,SO.ID,'_action']));
                if isnumeric(lData{1})
                    ft.setListObj(unique([lData{:}]));
                else
                    ft.setListObj(unique(lData));
                end

                result.addItem(ft.emitContent);
            end
        end
    end
    if isFixed
        set_param(bdroot(mdladvObj.System),'dirty','on');
    end
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
