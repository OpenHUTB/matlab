function varargout=variantPMConnectorddg_cb(action,varargin)





    dialogH=varargin{1};
    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end

    switch action

    case 'doEditVariantObj'
        i_doEditVariantObj(dialogH,block)

    case 'UpdateObject'
        i_doUpdate(varargin{1},varargin{2})

    case 'doClose'
        i_doClose(dialogH);

    case 'doPreApply'

        if~block.isHierarchyReadonly
            [noErr,msg]=i_doPreApply(dialogH,block);
        else
            msg='';noErr=true;
        end

        varargout{2}=msg;
        varargout{1}=noErr;

    case 'getVariantsData'
        varargout{1}=i_GetVariantsData(dialogH);

    case 'doVariantConnectorBlkType'
        i_doVariantConnectorBlkType(dialogH,block);

    case 'doConnectorTag'
        i_doConnectorTag(dialogH);

    case 'doShowVariantCondition'
        i_doShowVariantCondition(dialogH);
    end
end


function i_doRefresh(H,block)

    source=H.getSource;
    myData=source.UserData;



    if(isempty(myData.TableData))
        tableData=variantPMConnectorddg_cb('getVariantsData',block.Handle);
    else
        tableData=myData.TableData;






        variantControls=tableData(:,1:1);
        tableData=i_createVariantConditionTableData(block.Handle,variantControls);
    end


    myData.TableData=tableData;


    source.UserData=myData;

    H.refresh;
end


function i_doEditVariantObj(H,block)

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.TableData;

    row=H.getSelectedTableRow('VariantsTable');
    if(row<0)
        return;
    end


    object=tableData{row+1,1};
    object=strtrim(object);


    object=strrep(object,'%','');

    if~isempty(object)
        mdl=bdroot(block.getFullName);



        mustCreate=true;
        if existsInGlobalScope(mdl,object)
            if evalinGlobalScope(mdl,['isa(',object,', ''Simulink.Variant'');'])
                mustCreate=false;
            end
        end



        dataAccessor=Simulink.data.DataAccessor.createForExternalData(mdl);
        if mustCreate&&isvarname(object)
            dataAccessor.createVariableAsExternalData(object,Simulink.Variant);
        end


        varId=dataAccessor.identifyByName(object);
        if~(isempty(varId))
            dataAccessor.showVariableInUI(varId);
        end
    end
end



function i_doUpdate(object,name)

    try

        dlgs=DAStudio.ToolRoot.getOpenDialogs;

        for i=length(dlgs):-1:1
            if isempty(dlgs(i).getWidgetSource('VariantsTable'))
                dlgs(i)=[];
            end
        end

        for i=1:length(dlgs)

            H=dlgs(i);
            source=H.getSource;
            myData=source.UserData;
            tableData=myData.TableData;


            idxs=find(strcmp(tableData(:,1),name));
            if~isempty(idxs)
                for j=1:length(idxs)
                    tableData{idxs(j),2}=object.Condition;
                end
            end


            myData.TableData=tableData;
            source.UserData=myData;


            H.refresh;


            selectedRow=H.getSelectedTableRow('VariantsTable');

            if selectedRow~=-1
                varObject=strtrim(name);
            else
                varObject='';
            end
            if~isempty(varObject)
                if varObject(1)=='%'
                    H.setEnabled('EditVariantObjButton',isvarname(varObject(2:end)));
                else
                    H.setEnabled('EditVariantObjButton',isvarname(varObject));
                end
            else
                H.setEnabled('EditVariantObjButton',false);
            end
        end

    catch e %#ok
    end
end


function i_doClose(H)

    source=H.getSource;


    if isempty(DAStudio.ToolRoot.getOpenDialogs(H.getSource))
        source.UserData=[];
    end
end


function i_doConnectorTag(H)
    source=H.getSource;
    myData=source.UserData;
    sel=H.getWidgetValue('ConnectorTagEditBox');
    myData.ConnectorTag=sel;
    source.UserData=myData;
    syncAllOpenDialogs(source,H,'ConnectorTagEditBox',sel,'','');
end


function i_doVariantConnectorBlkType(H,block)
    source=H.getSource;
    myData=source.UserData;

    sel=H.getWidgetValue('ConnectorBlockTypeCombo');
    entries=myData.BlockTypeEntries;
    selVar=entries{sel+1};
    myData.ConnectorBlkType=selVar;
    syncAllOpenDialogs(source,H,'ConnectorBlockTypeCombo',sel,'')





    blockH=block.Handle;
    newBlkType=selVar;
    oldBlkType=get_param(blockH,'ConnectorBlkType');

    if(strcmp(newBlkType,'Primary')||strcmp(newBlkType,'Leaf'))&&strcmp(oldBlkType,'Nonprimary')&&isempty(myData.TableData)
        PortHand=get_param(blockH,'PortHandles');
        numPorts=length(PortHand.RConn);

        variantControls=cell(numPorts,1);
        for i=1:numPorts
            variantControls{i,1}=['choice_',num2str(i)];
        end

        tabledata=i_createVariantConditionTableData(blockH,variantControls);

        myData.TableData=tabledata;
        myData.TableItemChanged=1;
    end

    if~strcmp(newBlkType,'Leaf')&&strcmp(oldBlkType,'Leaf')&&isempty(myData.ConnectorTag)
        defaultConnectorTag='A';
        myData.ConnectorTag=defaultConnectorTag;
    end

    if strcmp(selVar,'Primary')||strcmp(newBlkType,'Leaf')


        H.setVisible('VariantConditionSettingPanel',true);
        syncAllOpenDialogs(source,H,'VariantConditionSettingPanel','','',true);


        H.setVisible('ShowVariantControlCheckbox',true);
        H.setEnabled('ShowVariantControlCheckbox',true);
        syncAllOpenDialogs(source,H,'ShowVariantControlCheckbox','',true,true);

    else


        H.setVisible('VariantConditionSettingPanel',false);
        syncAllOpenDialogs(source,H,'VariantConditionSettingPanel','','',false);


        H.setVisible('ShowVariantControlCheckbox',false);
        H.setEnabled('ShowVariantControlCheckbox',false);
        syncAllOpenDialogs(source,H,'ShowVariantControlCheckbox','',false,false);

    end

    source.UserData=myData;
    i_doRefresh(H,block);

end


function i_doShowVariantCondition(H)
    source=H.getSource;
    myData=source.UserData;

    selVal=H.getWidgetValue('ShowVariantControlCheckbox');
    if selVal
        myData.ShowConditionOnBlock='on';
    else
        myData.ShowConditionOnBlock='off';
    end
    source.UserData=myData;

    syncAllOpenDialogs(source,H,'ShowVariantControlCheckbox',selVal,'','');

end


function[success,err]=i_doPreApply(H,block)



    source=H.getSource;
    myData=source.UserData;
    variantControlData=myData.TableData;
    err='';success=true;
    varObjsChanged=myData.TableItemChanged;
    blockH=block.Handle;


    blkTypesel=H.getWidgetValue('ConnectorBlockTypeCombo');
    blkTypeEntries=myData.BlockTypeEntries;
    blkTypeSelVar=blkTypeEntries{blkTypesel+1};
    block.ConnectorBlkType=blkTypeSelVar;

    try
        if H.isVisible('ConnectorTagEditBox')
            oldConnectorTag=get_param(blockH,'ConnectorTag');
            newConnectorTag=H.getWidgetValue('ConnectorTagEditBox');
            if~strcmp(oldConnectorTag,newConnectorTag)
                set_param(blockH,'ConnectorTag',newConnectorTag);
            end
        end

    catch ex
        err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
        success=false;
    end

    try

        if H.isEnabled('ShowVariantControlCheckbox')
            oldIconVal=get_param(blockH,'ShowConditionOnBlock');
            val=H.getWidgetValue('ShowVariantControlCheckbox');

            if val
                newIconVal='on';
            else
                newIconVal='off';
            end

            if~strcmp(oldIconVal,newIconVal)
                set_param(blockH,'ShowConditionOnBlock',newIconVal);
            end
        end
    catch ex
        err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
        success=false;
    end



    blockType=get_param(blockH,'ConnectorBlkType');
    if varObjsChanged&&(strcmp(blockType,'Primary')||strcmp(blockType,'Leaf'))
        try

            set_param(blockH,'VariantControls',variantControlData(:,1));
        catch ex
            err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
            success=false;

            if H.isEnabled('ShowVariantControlCheckbox')
                set_param(blockH,'ShowConditionOnBlock',oldIconVal);
            end




            tableData=variantPMConnectorddg_cb('getVariantsData',block.Handle);
            myData.TableData=tableData;
            source.UserData=myData;
        end
    end




    i_doRefresh(H,block)

end


function tableData=i_GetVariantsData(h)

    info=get_param(h,'VariantControls');

    info=info(:).';
    PortHand=get_param(h,'PortHandles');
    numPorts=length(PortHand.RConn);




    connectorBlkType=get_param(h,'ConnectorBlkType');
    if~strcmp(connectorBlkType,'Nonprimary')

        if isempty(info)
            variantControls=repmat({'Choice'},1,numPorts);
            newVariantControls=matlab.lang.makeUniqueStrings(variantControls);
            set_param(h,'VariantControls',newVariantControls);


        elseif numPorts>length(info)
            variantControlsCopy=[info,repmat({'Choice'},1,numPorts-length(info))];
            newVariantControls=matlab.lang.makeUniqueStrings(variantControlsCopy);
            set_param(h,'VariantControls',newVariantControls);
        end
    end

    info=get_param(h,'VariantControls');


    tableData=i_createVariantConditionTableData(h,info);

end







function tableData=i_createVariantConditionTableData(h,variantControls)
    rows=length(variantControls);


    tableData=cell(rows,2);
    for i=1:rows


        tableData{i,1}=strtrim(variantControls{i});


        varControlName=variantControls{i};
        if isempty(varControlName)||varControlName(1)=='%'
            condValue=DAStudio.message('Simulink:Variants:Ignored');
        else
            condValue=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');
        end

        if Simulink.variant.keywords.isValidVariantKeyword(varControlName)
            isVariantObject=false;
        else
            isVariantObject=slprivate('isVariantControlVariantObject',h,varControlName);
        end

        if isVariantObject
            try
                condValue=evalinGlobalScope(bdroot,[varControlName,'.Condition']);
            catch err %#ok
                condValue=DAStudio.message('Simulink:dialog:NoVariantObject');
            end
        end

        tableData{i,2}=condValue;

    end
end

