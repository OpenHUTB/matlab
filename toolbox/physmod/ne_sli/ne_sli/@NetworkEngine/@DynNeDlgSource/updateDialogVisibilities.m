function updateDialogVisibilities(hThis,hDialog)







    blkH=pmsl_getdoublehandle(hThis.BlockHandle);
    cs=physmod.schema.internal.blockComponentSchema(blkH,hThis.ComponentName);
    i=cs.info();

    tagList=lGetDialogTags(hDialog);
    paramTagMap=lGetParameterTagMap(i.Members.Parameters,tagList);
    ctrls=lControlTableFromDialog(hDialog,...
    cs.defaultControls(),...
    i.Members.Parameters,...
    paramTagMap);


    paramIds={i.Members.Parameters.ID};
    paramVis=simscape.schema.internal.visible(paramIds,cs,ctrls);

    varIds={i.Members.Variables.ID};
    varVis=simscape.schema.internal.visible(varIds,cs,ctrls);


    pTagVis=lParamTagVisibilities(paramVis,paramTagMap);
    arrayfun(@(item)hDialog.setVisible(item.Tag,item.Visible),pTagVis);


    varTagMap=lGetVariableTagMap(i.Members.Variables,tagList);
    varSpec=lVarSpecifyValuesFromDialog(hDialog,varTagMap);
    vTagVis=lVarTagVisibilities(varVis,varTagMap,varSpec);
    arrayfun(@(item)hDialog.setVisible(item.Tag,item.Visible),vTagVis);


    tabTagMap=lGetTabTagMap(hDialog);
    tabLabels=pm.sli.internal.resolveMessageStrings(...
    {i.Members.Parameters.Group,i.Members.Variables.Group});
    itemVis=[paramVis,varVis];
    tabVis=arrayfun(...
    @(item)any(itemVis(strcmp(item.Label,tabLabels))),tabTagMap);
    arrayfun(@(tab,vis)hDialog.setVisible(tab.Tag,vis),tabTagMap,tabVis);


    hDialog.resetSize(false);
    hDialog.resetSize(false);
end

function tagVis=lParamTagVisibilities(paramVis,paramMap)
    tagVis=struct('Tag',{},'Visible',{});
    for iParam=1:numel(paramVis)
        paramTags=struct2cell(paramMap(iParam));
        for iTag=1:numel(paramTags)
            if~ismissing(paramTags{iTag})
                tagVis(end+1).Tag=paramTags{iTag};%#ok<AGROW>
                tagVis(end).Visible=paramVis(iParam);
            end
        end
    end
end

function[tagVis,varVis]=lVarTagVisibilities(varVis,varMap,varSpec)
    tagVis=struct('Tag',{},'Visible',{});
    for iVar=1:numel(varVis)
        varTags=struct2cell(varMap(iVar));
        for iTag=1:numel(varTags)
            if~ismissing(varTags{iTag})
                tagVis=[tagVis,...
                lVarVisStruct(varTags{iTag},varVis(iVar),varSpec(iVar))];%#ok<AGROW>
            end
        end
    end
end

function s=lVarVisStruct(tag,vis,spec)
    if iscell(tag)
        defTag=endsWith(tag,'_default');
        s.Tag=tag{defTag};
        s.Visible=vis&&~spec;
        s(2).Tag=tag{~defTag};
        s(2).Visible=vis&&spec;
    else
        s.Tag=tag;
        s.Visible=vis;
    end
end

function tagList=lGetDialogTags(hDialog)


    tagList={};
    hIMWidgets=DAStudio.imDialog.getIMWidgets(hDialog);
    hToolObj=find(hIMWidgets);
    if(~isempty(hToolObj))

        tagList=get(hToolObj(2:end),'Tag');
    end

end

function tabTagMap=lGetTabTagMap(hDialog)

    hIMWidgets=DAStudio.imDialog.getIMWidgets(hDialog);
    hToolObj=find(hIMWidgets);
    tabObjs=hToolObj(arrayfun(@(item)isa(item,'DAStudio.imTab'),hToolObj));
    tabLabels=arrayfun(@(item)item.getName(),tabObjs,'UniformOutput',false);
    tabTags=arrayfun(@(item)item.tag,tabObjs,'UniformOutput',false);
    tabTagMap=struct('Label',tabLabels,'Tag',tabTags);

end

function match=lMatch(tagList,substr)
    match=missing;
    b=contains(tagList,['.',substr,'.']);
    if nnz(b)==1
        match=tagList{b};
    elseif nnz(b)>1
        match=tagList(b);
    end
end

function pTags=lGetParameterTagMap(params,tagList)
    pTags=repmat(struct('Value',{''},'Unit',{''},'Label',{''},'Conf',{''}),size(params));
    for idx=1:numel(params)
        pTags(idx).Value=lMatch(tagList,params(idx).ID);
        pTags(idx).Unit=lMatch(tagList,[params(idx).ID,'_unit']);
        pTags(idx).Label=lMatch(tagList,[params(idx).ID,'_label']);
        pTags(idx).Conf=lMatch(tagList,[params(idx).ID,'_conf']);
    end
end

function vTags=lGetVariableTagMap(vars,tagList)
    vTags=repmat(struct('Value',{''},'Unit',{''},'Label',{''},'Priority',{''},'Specify',{''}),size(vars));
    for idx=1:numel(vars)
        vTags(idx).Value=lMatch(tagList,vars(idx).ID);
        vTags(idx).Unit=lMatch(tagList,[vars(idx).ID,'_unit']);
        vTags(idx).Label=lMatch(tagList,[vars(idx).ID,'_label']);
        vTags(idx).Priority=lMatch(tagList,[vars(idx).ID,'_priority']);
        vTags(idx).Specify=lMatch(tagList,[vars(idx).ID,'_specify']);
    end
end

function ctrls=lControlTableFromDialog(hDialog,ctrls,params,paramMap)


    paramIds={params.ID};
    for idx=1:numel(ctrls)
        bParam=strcmp(ctrls(idx).ID,paramIds);
        tag=paramMap(bParam).Value;
        if~ismissing(tag)
            val=hDialog.getWidgetValue(tag);
            p=params(bParam);
            if isnumeric(val)
                if(val<numel(p.Choices))
                    ctrls(idx).Value=p.Choices(val+1).Value;
                elseif(strcmp(p.Default.Value,'true')||...
                    strcmp(p.Default.Value,'false'))
                    ch=[true,false];
                    ctrls(idx).Value=simscape.Value(ch(val+1));
                else
                    enumData=pm.sli.getEnumData(p.Default.Value);
                    if(val<numel(enumData.enumValues))
                        ctrls(idx).Value=simscape.Value(enumData.enumValues(val+1));
                    end
                end
            end
        end
    end
end

function specs=lVarSpecifyValuesFromDialog(hDialog,varMap)
    specs=nan(size(varMap));
    for idx=1:numel(varMap)
        if~ismissing(varMap(idx).Specify)
            specs(idx)=hDialog.getWidgetValue(varMap(idx).Specify);
        end
    end
end
