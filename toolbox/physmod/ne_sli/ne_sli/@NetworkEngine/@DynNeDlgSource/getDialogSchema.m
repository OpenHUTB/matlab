function dlgStruct=getDialogSchema(hThis,type)















    slimType='Simscape:Description:';
    if startsWith(type,slimType)
        args=extractAfter(type,slimType);
        if~isempty(args)
            fcn=nesl_private('nesl_create_errorschema');
            dlgStruct=fcn(pmsl_getdoublehandle(hThis.BlockHandle),args);
            return
        end
    end


    dlgStruct=pmsl_superclassmethod(hThis,...
    'NetworkEngine.DynNeDlgSource','getDialogSchema',type);





    if isempty(type)&&~isempty(hThis.ComponentName)&&~hThis.RequestChooser


        try
            blkH=pmsl_getdoublehandle(hThis.BlockHandle);
            cs=physmod.schema.internal.blockComponentSchema(blkH,hThis.ComponentName);
            ctrls=lUpdateControlTable(dlgStruct,cs.defaultControls());
            dlgStruct=lUpdateVisibilities(dlgStruct,cs,ctrls);
        catch

            return;
        end
    end

end

function ctrls=lUpdateControlTable(dlgStruct,ctrls)






    if isfield(dlgStruct,'Source')&&(...
        isa(dlgStruct.Source,'NetworkEngine.DynGuiDropDown'))
        hSource=dlgStruct.Source;
        iCtrl=find(strcmp({ctrls.ID},hSource.ValueBlkParam),1,'first');
        if~isempty(iCtrl)
            iVal=find(strcmp(hSource.Choices,hSource.Value),1,'first');
            if~isempty(iVal)&&numel(hSource.ChoiceVals)>=iVal
                ctrls(iCtrl).Value=simscape.Value(hSource.ChoiceVals(iVal));
            end
        end
    else

        chField='';
        if isfield(dlgStruct,'Items')
            chField='Items';
        elseif isfield(dlgStruct,'Tabs')
            chField='Tabs';
        end
        if~isempty(chField)
            ch=dlgStruct.(chField);
            for idx=1:numel(ch)
                ctrls=lUpdateControlTable(ch{idx},ctrls);
            end
        end
    end
end

function dlgStruct=lUpdateVisibilities(dlgStruct,cs,ctrls)
    i=cs.info();
    tabIDs={i.Members.Parameters.Group,i.Members.Variables.Group};
    uniqueTabs=unique(tabIDs);
    paramIds={i.Members.Parameters.ID};
    paramVis=simscape.schema.internal.visible(paramIds,cs,ctrls);
    varIds={i.Members.Variables.ID};
    varVis=simscape.schema.internal.visible(varIds,cs,ctrls);
    itemVis=[paramVis,varVis];
    tabVis=cellfun(...
    @(item)any(itemVis(strcmp(item,tabIDs))),uniqueTabs);
    tabMap=containers.Map('KeyType','char','ValueType','logical');
    if numel(tabVis)>0
        tabMap=containers.Map(...
        pm.sli.internal.resolveMessageStrings(uniqueTabs),tabVis);
    end
    params=struct('ID',paramIds,'Visible',num2cell(paramVis));
    vars=struct('ID',varIds,'Visible',num2cell(varVis));
    dlgStruct=lUpdateStruct(dlgStruct,params,vars,tabMap);



    dlgStruct=rmfield(dlgStruct,'Visible');
end

function strct=lUpdateStruct(strct,params,vars,tabMap)
    paramIds={params.ID};
    if isfield(strct,'Tag')



        iParam=[];
        maybeParam=regexp(strct.Tag,'(?<=\.)\w*(?=\.\w*$)','match','once');
        if~isempty(maybeParam)
            prm=regexp(maybeParam,'\w*(?=(_unit|_conf|_label)$)','match','once');
            if~isempty(prm)
                iParam=strcmp(prm,paramIds);
            else
                iParam=strcmp(maybeParam,paramIds);
            end
        end
        if nnz(iParam)==1
            strct.Visible=params(iParam).Visible;
            return;
        end
        varTargets=startsWith(strct.Tag,'NetworkEngine.DynNeVariableTargets.');
        if varTargets
            itemTags=cellfun(@(item)item.Tag,strct.Items,'UniformOutput',false);
            for iVar=1:numel(vars)
                if~vars(iVar).Visible
                    varItem=endsWith(itemTags,['.',vars(iVar).ID,'.Edit']);
                    row=strct.Items{varItem}.RowSpan(1);
                    for iItem=1:numel(strct.Items)
                        if strct.Items{iItem}.RowSpan(1)==row
                            strct.Items{iItem}.Visible=false;
                        end
                    end
                end
            end
            return;
        end
    end

    if isfield(strct,'Items')
        for iItem=1:numel(strct.Items)
            strct.Items{iItem}=lUpdateStruct(strct.Items{iItem},params,vars,tabMap);
        end
        strct.Visible=lAnyVisibleChildren(strct.Items);
    elseif isfield(strct,'Tabs')
        for iTab=1:numel(strct.Tabs)
            strct.Tabs{iTab}=lUpdateStruct(strct.Tabs{iTab},params,vars,tabMap);


            strct.Tabs{iTab}.Visible=tabMap(strct.Tabs{iTab}.Name);
        end
        strct.Visible=lAnyVisibleChildren(strct.Tabs);
    end
end

function res=lAnyVisibleChildren(items)
    res=any(cellfun(@lVisible,items));
    function out=lVisible(item)
        out=true;
        if isfield(item,'Visible')
            out=item.Visible;
        end
    end
end
