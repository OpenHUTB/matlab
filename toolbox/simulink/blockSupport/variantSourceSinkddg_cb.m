function varargout=variantSourceSinkddg_cb(action,varargin)




    dialogH=varargin{1};
    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end




    switch action
    case 'doAddPort'
        i_doAddPort(dialogH,block)

    case 'doDeletePort'
        i_doDeletePort(dialogH,block)

    case 'doEdit'
        i_doEdit(dialogH,block)

    case 'UpdateObject'
        i_doUpdate(varargin{1},varargin{2})

    case 'doClose'
        i_doClose(dialogH);

    case 'doOverride'
        i_doOverride(dialogH,block);

    case 'doVCType'
        i_doVCType(dialogH,block);

    case 'doSetVariantActivationTime'
        i_doSetVariantActivationTime(dialogH,block);

    case 'doAZVCCheckbox'
        i_doAZVCCheckbox(dialogH,block);

    case 'doOutputFunctionCallCheckbox'
        i_doOutputFunctionCallCheckbox(dialogH,block);

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
    end
end


function i_doAddPort(H,block)
    blockH=block.Handle;
    source=H.getSource;
    myData=source.UserData;


    variantControls=get_param(blockH,'VariantControls');

    sel=H.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VariantControlMode=selVar;

    if strcmp(selVar,'sim codegen switching')
        simKeyW=Simulink.variant.keywords.getSimVariantKeyword();
        codegenKeyW=Simulink.variant.keywords.getCodegenVariantKeyword();
        if strcmp(simKeyW,strtrim(variantControls{1}))
            variantControls{end+1}=codegenKeyW;
        else
            variantControls{end+1}=simKeyW;
        end
    else
        variantControls{end+1}=createDummyVariantControl(blockH);
    end


    set_param(blockH,'VariantControls',variantControls);


    source=H.getSource;
    myData=source.UserData;
    tableData=myData.TableData;
    rowIdx=size(tableData,1)+1;

    tableData{rowIdx,1}=sprintf('%d',rowIdx);
    tableData{rowIdx,2}=variantControls{end};
    tableData{rowIdx,3}=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');

    myData.TableData=tableData;
    source.UserData=myData;


    H.refresh;
    H.selectTableRow('VariantsTable',rowIdx-1);


    if strcmp(selVar,'expression')

        H.setEnabled('EditButton',true);
    end

end


function i_doDeletePort(H,block)
    blockH=block.Handle;

    row=H.getSelectedTableRow('VariantsTable');
    if(row<0)
        return;
    end

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.TableData;
    tableData(row+1,:)=[];
    rows=size(tableData,1);

    for i=row+1:rows
        tableData{i,1}=sprintf('%d',i);
    end
    myData.TableData=tableData;
    source.UserData=myData;

    Simulink.variant.utils.deleteVariantSourceSinkPort(blockH,row+1);


    H.selectTableRow('VariantsTable',0);

    H.refresh;
end


function i_doEdit(H,block)

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.TableData;

    row=H.getSelectedTableRow('VariantsTable');
    if(row<0)
        return;
    end


    object=tableData{row+1,2};
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


            idxs=find(strcmp(tableData(:,2),name));
            if~isempty(idxs)
                for j=1:length(idxs)
                    tableData{idxs(j),3}=object.Condition;
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
                    H.setEnabled('EditButton',isvarname(varObject(2:end)));
                else
                    H.setEnabled('EditButton',isvarname(varObject));
                end
            else
                H.setEnabled('EditButton',false);
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


function i_doOverride(H,~)

    source=H.getSource;
    myData=source.UserData;

    sel=H.getWidgetValue('OverrideVariantCombo');
    entries=myData.Entries;
    if~isempty(entries)
        selVar=entries{sel+1};
        myData.OverrideVariant=selVar;
    end

    syncAllOpenDialogs(source,H,'OverrideVariantCombo',sel,'');

    source.UserData=myData;
end


function i_doAZVCCheckbox(H,~)

    source=H.getSource;
    myData=source.UserData;


    sel=H.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VariantControlMode=selVar;
    if~strcmp(selVar,'expression')
        return;
    end


    val=H.getWidgetValue('InlineVariantBlockAllowZeroConditionCheckbox');
    if val
        myData.AZVC='on';
    else
        myData.AZVC='off';
    end
    syncAllOpenDialogs(source,H,'InlineVariantBlockAllowZeroConditionCheckbox',val,'');

    source.UserData=myData;

end


function i_doOutputFunctionCallCheckbox(H,~)



    source=H.getSource;
    myData=source.UserData;


    myData.OFC=H.getWidgetValue('VariantOutputFunctionCallCheckbox');

    syncAllOpenDialogs(source,H,'VariantOutputFunctionCallCheckbox',myData.OFC,'');

    source.UserData=myData;

end

function i_doSetVariantActivationTime(H,block)




    source=H.getSource;
    myData=source.UserData;

    VATIdx=H.getWidgetValue('VariantActivationTimeCombo');
    entries=myData.VATypeEntries;
    selVar=entries{VATIdx+1};
    myData.VariantActivationTime=selVar;

    VCMode=myData.VCType;
    selVATDesc=Simulink.variant.ddgutils.getVariantModeDescription(VCMode,selVar);

    H.setWidgetValue('VC_VATDescription',selVATDesc);
    syncAllOpenDialogs(source,H,'VariantActivationTimeCombo',VATIdx,'');
    syncAllOpenDialogs(source,H,'VC_VATDescription',selVATDesc,'');

    [ofcVis,~]=Simulink.variant.ddgutils.getOutputFunctionCallStatus(block,myData);
    H.setVisible('VariantOutputFunctionCallCheckbox',ofcVis);
    syncAllOpenDialogs(source,H,'VariantOutputFunctionCallCheckbox','','',ofcVis);

    source.UserData=myData;

end


function i_doVCType(H,block)

    source=H.getSource;
    myData=source.UserData;

    sel=H.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VCType=selVar;
    syncAllOpenDialogs(source,H,'VariantControlModeCombo',sel,'')

    isLabelVCMode=strcmp('label',selVar);
    isExpressionVCMode=~isLabelVCMode&&strcmp('expression',selVar);
    isSimCodegenVCMode=~isLabelVCMode&&~isExpressionVCMode...
    &&strcmp('sim codegen switching',selVar);

    H.setVisible('LabelGroup',isLabelVCMode);
    syncAllOpenDialogs(source,H,'LabelGroup','','',isLabelVCMode);

    H.setVisible('OverrideVariantCombo',isLabelVCMode);
    syncAllOpenDialogs(source,H,'OverrideVariantCombo','','',isLabelVCMode);

    H.setVisible('InlineVariantBlockAllowZeroConditionCheckbox',isExpressionVCMode);
    azvcCanBeEnabled=Simulink.isParameterEnabled(block.Handle,'AllowZeroVariantControls');
    H.setEnabled('InlineVariantBlockAllowZeroConditionCheckbox',isExpressionVCMode&&azvcCanBeEnabled);
    syncAllOpenDialogs(source,H,'InlineVariantBlockAllowZeroConditionCheckbox','',isExpressionVCMode&&azvcCanBeEnabled,isExpressionVCMode);

    visStat=Simulink.variant.ddgutils.getOutputFunctionCallStatus(block,myData);
    H.setVisible('VariantOutputFunctionCallCheckbox',visStat);
    syncAllOpenDialogs(source,H,'VariantOutputFunctionCallCheckbox','','',visStat);

    syncAllOpenDialogs(source,H,'EditButton',isExpressionVCMode,'');
    H.setVisible('VariantActivationTimeCombo',isExpressionVCMode||isSimCodegenVCMode);
    H.setEnabled('VariantActivationTimeCombo',isExpressionVCMode||isSimCodegenVCMode);
    syncAllOpenDialogs(source,H,'VariantActivationTimeCombo','',isExpressionVCMode||isSimCodegenVCMode,isExpressionVCMode||isSimCodegenVCMode);

    VAT=myData.VariantActivationTime;
    selVATDesc=Simulink.variant.ddgutils.getVariantModeDescription(selVar,VAT);
    syncAllOpenDialogs(source,H,'VC_VATDescription',selVATDesc,'');

    source.UserData=myData;

    H.refresh;
end


function[success,err]=i_doPreApply(H,block)



    source=H.getSource;
    myData=source.UserData;
    data=myData.TableData;
    err='';success=true;
    varCtrlChanged=myData.TableItemChanged;
    blockH=block.Handle;

    try

        oldGpcVal=get_param(blockH,'GeneratePreprocessorConditionals');
        oldCondIconVal=get_param(blockH,'ShowConditionOnBlock');
        oldAZVCVal=get_param(blockH,'AllowZeroVariantControls');
        oldOFCVal=get_param(blockH,'OutputFunctionCall');
        oldLabelVal=block.LabelModeActiveChoice;
        oldVCMVal=block.VariantControlMode;
        oldVATVal=block.VariantActivationTime;


        if H.isEnabled('InlineVariantBlockIconCheckbox')
            val=H.getWidgetValue('InlineVariantBlockIconCheckbox');
            if val~=strcmp(oldCondIconVal,'on')
                if val
                    set_param(blockH,'ShowConditionOnBlock','on');
                else
                    set_param(blockH,'ShowConditionOnBlock','off');
                end
            end
        end


        if H.isEnabled('InlineVariantBlockAllowZeroConditionCheckbox')
            val=H.getWidgetValue('InlineVariantBlockAllowZeroConditionCheckbox');
            if val~=strcmp(oldAZVCVal,'on')
                if val
                    set_param(blockH,'AllowZeroVariantControls','on');
                else
                    set_param(blockH,'AllowZeroVariantControls','off');
                end
            end
        end

        if H.isVisible('VariantOutputFunctionCallCheckbox')
            val=H.getWidgetValue('VariantOutputFunctionCallCheckbox');
            valStr='on';
            if val==false
                valStr='off';
            end
            if~strcmp(oldOFCVal,valStr)
                set_param(blockH,'OutputFunctionCall',valStr);
            end
        end


        selected=H.getWidgetValue('VariantControlModeCombo');
        VCTypeEntries=myData.VCTypeEntries;
        selVCMVar=VCTypeEntries{selected+1};
        block.VariantControlMode=selVCMVar;








        if(strcmp(oldVCMVal,'expression')&&strcmp(selVCMVar,'sim codegen switching'))||...
            (strcmp(selVCMVar,'expression')&&strcmp(oldVCMVal,'sim codegen switching'))
            varCtrlChanged=true;
        end


        if H.isEnabled('VariantActivationTimeCombo')
            selection=H.getWidgetValue('VariantActivationTimeCombo');
            VATypeEntries=myData.VATypeEntries;
            selVATVal=VATypeEntries{selection+1};
            block.VariantActivationTime=selVATVal;
        end


        if varCtrlChanged

            set_param(blockH,'VariantControls',data(:,2));
        end


        if H.isVisible('OverrideVariantCombo')
            sel=H.getWidgetValue('OverrideVariantCombo');




            entries=get_param(blockH,'VariantControls');
            if~isempty(entries)
                labelVal=entries{sel+1};
            else
                labelVal='';
            end
        else
            labelVal='';
        end
        block.LabelModeActiveChoice=labelVal;
    catch ex
        err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
        success=false;
        if H.isEnabled('InlineVariantBlockIconCheckbox')
            set_param(blockH,'ShowConditionOnBlock',oldCondIconVal);
        end
        if H.isEnabled('InlineVariantBlockAllowZeroConditionCheckbox')
            set_param(blockH,'AllowZeroVariantControls',oldAZVCVal);
        end

        if H.isEnabled('VariantOutputFunctionCallCheckbox')
            set_param(blockH,'OutputFunctionCall',oldOFCVal);
        end

        if H.isEnabled('GeneratePreprocessorCheckbox')
            set_param(blockH,'GeneratePreprocessorConditionals',oldGpcVal);
        end
        if H.isVisible('OverrideVariantCombo')
            block.LabelModeActiveChoice=oldLabelVal;
        end
        if H.isEnabled('VariantControlModeCombo')
            block.VariantControlMode=oldVCMVal;
        end
        if H.isEnabled('VariantActivationTimeCombo')
            block.VariantActivationTime=oldVATVal;
        end
    end



    H.refresh;

end


function tableData=i_GetVariantsData(h)

    info=get_param(h,'VariantControls');


    info=info(:).';
    PortHand=get_param(h,'PortHandles');
    numPorts=length(PortHand.Outport);
    if(numPorts==1)
        numPorts=length(PortHand.Inport);
    end



    if isempty(info)
        variantControls=repmat({'Choice'},1,numPorts);
        newVariantControls=matlab.lang.makeUniqueStrings(variantControls);
        set_param(h,'VariantControls',newVariantControls);


    elseif numPorts>length(info)
        variantControlsCopy=[info,repmat({'Choice'},1,numPorts-length(info))];
        newVariantControls=matlab.lang.makeUniqueStrings(variantControlsCopy);
        set_param(h,'VariantControls',newVariantControls);
    end

    info=get_param(h,'VariantControls');

    rows=length(info);



    tableData=cell(rows,3);

    for i=1:rows


        tableData{i,1}=sprintf('%d',i);


        tableData{i,2}=strtrim(info{i});


        varControlName=info{i};
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

        tableData{i,3}=condValue;

    end
end



