function varargout=subsysVariantsddg_cb(action,varargin)






    dialogH=varargin{1};
    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end

    switch action
    case 'doAddSubsys'
        i_doAddChoice(dialogH,block,'SubSystem')

    case 'doAddModel'
        i_doAddChoice(dialogH,block,'ModelReference')

    case 'doOpen'
        i_doOpen(dialogH,block)

    case 'doEdit'
        i_doEdit(dialogH,block)

    case 'UpdateObject'
        i_doUpdate(varargin{1},varargin{2})

    case 'doRefresh'
        i_doRefresh(dialogH,block);

    case 'doOpenME'
        i_doOpenME(dialogH);

    case 'doClose'
        i_doClose(dialogH);

    case 'doVCType'
        i_doVCType(dialogH,block);

    case 'doSetVariantActivationTime'
        i_doSetVariantActivationTime(dialogH,block);

    case 'doAZVCCheckbox'
        i_doAZVCCheckbox(dialogH,block);

    case 'doOverride'
        i_doOverride(dialogH,block);

    case 'doPreApply'

        if~block.isHierarchyReadonly
            [noErr,msg]=i_doPreApply(dialogH,block);


        else
            msg='';noErr=true;
        end

        varargout{2}=msg;
        varargout{1}=noErr;

    case 'doConvertToVAS'
        i_doConvertToVAS(dialogH,block)

    case 'doValidateButton'
        i_doValidateButton(dialogH,block);

    case 'getVariantsData'
        varargout{1}=i_GetVariantsData(dialogH);

    case 'getRefTabVarTableDataFromFilenames'
        assert(length(varargin)==1);
        varargout{1}=i_getRefTabVarTableDataFromFilenames(varargin{1});

    case 'getWarningDisplayText'
        varargout{1}=i_getWarningDisplayText(varargin{1});

    otherwise
        error(['assert - bad action, ',action]);
    end

end


function warnDispText=i_getWarningDisplayText(ex)
    if isempty(ex)||isempty(ex.cause)||...
        ~strcmp(ex.identifier,'Simulink:Variants:VASErrorInVarSelEval')
        warnDispText='';
        return;
    end
    exCause=ex.cause{1};
    if~strcmp(exCause.identifier,'MATLAB:UndefinedFunction')
        warnDispText='';
        return;
    end
    warnDispText=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(exCause);
end


function varTableData=i_getRefTabVarTableDataFromFilenames(fileNames)
    if isempty(fileNames)
        varTableData=cell(0,2);
    else
        choiceFilePaths=cellfun(@(fileName)fileparts(which(fileName)),fileNames,'UniformOutput',false);
        varTableData=[fileNames,choiceFilePaths];
    end
end


function i_ErrorOutIfVariantControlModeNotLabelInDialog(dlg)
    vcmIndexValue=dlg.getWidgetValue('VariantControlModeCombo');
    if vcmIndexValue~=1
        exMain=MSLException(message('Simulink:Variants:UnableToConvert',dlg.getSource.getBlock.getFullName));
        exCause=MSLException(message('Simulink:Variants:VCMNotLabel'));
        exMain.addCause(exCause).throwAsCaller;
    end
end




function i_doConvertToVAS(dialogH,block)


    i_ErrorOutIfVariantControlModeNotLabelInDialog(dialogH);

    try
        Simulink.VariantManager.convertToVariantAssemblySubsystem(block.Handle);
        dialogH.getSource.UserData=[];
        dialogH.refresh;
    catch ex
        errCause=ex.cause;
        if isempty(errCause)||~strcmp(errCause{1}.identifier,'Simulink:Variants:FolderPathReq')
            throw(ex)
        end

        Simulink.variant.vas.SSChoicesToSSRefChoicesConvertDlg.createAndLaunchSSChoicesToSSRefChoicesConvertDlg(...
        block.Handle,dialogH);
    end
end


function i_updateVASUserData(source,choiceSelector,refTabVarTableData,warnDispText)
    myVASData=source.UserData;

    myVASData.ChoiceSelector=choiceSelector;
    myVASData.RefTabVarTableData=refTabVarTableData;
    myVASData.WarningDisplayText=warnDispText;

    source.UserData=myVASData;
end


function err=i_getErrMsgToDisplayInDialog(ex)
    err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);


    err=strrep(err,newline,'<br>');
end


function i_ErrorOutIfVariantChoicesSpecifierIsEmpty(choiceSelector)
    if isempty(choiceSelector)
        DAStudio.error('Simulink:Variants:EmptyVarChocSpec');
    end
end

function disableUIElementsAndEnableValidatingText(dlg)
    dlg.setVisible('GroupDisplayWarningMessage',false);
    dlg.setEnabled('ChoiceSelectorEdit',false);
    dlg.setEnabled('ValidateChoiceSelectorPushbutton',false);
    dlg.setVisible('GroupValidatingVCS',true);
end


function i_doValidateButton(dialogH,block)

    choiceSelector=dialogH.getWidgetValue('ChoiceSelectorEdit');


    i_ErrorOutIfVariantChoicesSpecifierIsEmpty(choiceSelector);

    source=dialogH.getSource;

    disableUIElementsAndEnableValidatingText(dialogH);

    err='';
    warnDispText='';
    try
        fileNames=...
        slInternal('EvaluateVASChoiceSelectorAndGetListOfModelAndSubsystem',block.getFullName,choiceSelector);
    catch ex
        warnDispText=i_getWarningDisplayText(ex);
        fileNames={};

        if isempty(warnDispText)
            err=ex;
        end
    end

    i_updateVASUserData(source,choiceSelector,...
    i_getRefTabVarTableDataFromFilenames(fileNames),warnDispText);

    dialogH.refresh;

    if~isempty(err)
        err.throwAsCaller;
    end
end


function i_doAddChoice(H,block,choiceType)

    choiceIsSubsystem=strcmp(choiceType,'SubSystem');
    newBlkName='Subsystem';
    if~choiceIsSubsystem
        assert(strcmp(choiceType,'ModelReference'));
        newBlkName='Model';
    end

    blk=block.Handle;
    choice_subsys=find_system(blk,'SearchDepth',1,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem');
    choice_mdlref=find_system(blk,'SearchDepth',1,'LookUnderMasks',...
    'on','MatchFilter',@Simulink.match.allVariants,'BlockType','ModelReference');

    choices=[choice_subsys(2:end);choice_mdlref];
    num=length(choices);
    ins=find_system(blk,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','on','BlockType','Inport');
    outs=find_system(blk,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','on','BlockType','Outport');










    ymax=0;
    for ii=1:num
        temp=get_param(choices(ii),'Position');
        if temp(4)>ymax
            ymax=temp(4);
            x=temp(1);
        end
    end

    xinr=80;
    y=ymax+70;
    xoutl=0;



    if(num==0)
        if~isempty(ins)&&~isempty(outs)
            posin=get_param(ins(end),'Position');
            posout=get_param(outs(end),'Position');
            xinr=posin(3);
            xoutl=posout(1);
            x=xinr+(xoutl-xinr)/2-15;
        elseif~isempty(ins)
            posin=get_param(ins(end),'Position');
            x=posin(3)+60;
        elseif~isempty(outs)
            posout=get_param(outs(end),'Position');
            x=max(posout(1)-110,50);
        else
            pos=get_param(blk,'Position');
            xmin=max(pos(1),140);
            x=xmin+floor((pos(3)-pos(1))/2);
        end
    end


    variantsParam=get_param(blk,'Variants');
    sel=H.getWidgetValue('VariantControlModeCombo');
    source=H.getSource;
    myData=source.UserData;
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VariantControlMode=selVar;

    if strcmp(selVar,'sim codegen switching')
        simKeyW=Simulink.variant.keywords.getSimVariantKeyword();
        codegenKeyW=Simulink.variant.keywords.getCodegenVariantKeyword();
        newVCName=simKeyW;


        if~isempty(variantsParam)...
            &&strcmp(simKeyW,strtrim(variantsParam(1).Name))
            newVCName=codegenKeyW;
        end
    else
        newVCName=createDummyVariantControl(blk);
    end



    dirtyFlag=get_param(bdroot(blk),'Dirty');
    try
        newBlk=add_block(...
        ['built-in/',choiceType],...
        [getfullname(blk),'/',newBlkName],...
        'MakeNameUnique','on',...
        'Position',[x,y,x+50,y+50],...
        'VariantControl',newVCName);
    catch ex


        if strcmp(dirtyFlag,'off')
            set_param(bdroot(blk),'Dirty','off');
        end
        throw(ex);
    end


    if choiceIsSubsystem
        name=getfullname(newBlk);
        newPos=get_param(newBlk,'Position');


        for i=1:length(ins)
            blkName=strrep(get_param(ins(i),'Name'),'/','//');
            add_block('built-in/Inport',[name,'/',blkName],...
            'Position',[xinr-30,50*i,xinr,50*i+15])
        end


        if(xoutl==0)
            xoutl=newPos(3)+60;
        end
        for i=1:length(outs)
            blkName=strrep(get_param(outs(i),'Name'),'/','//');
            add_block('built-in/Outport',[name,'/',blkName],...
            'Position',[xoutl,50*i,xoutl+30,50*i+15])
        end
    end


    hilite_system(newBlk,'none');
    set_param(newBlk,'Selected','on')

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.MainTabVarTableData;


    bH=get_param(newBlk,'Handle');
    blkName=strrep(get_param(bH,'Name'),newline,' ');
    rowIdx=size(tableData,1)+1;
    tableData{rowIdx,1}=bH;
    tableData{rowIdx,2}=blkName;
    tableData{rowIdx,3}=newVCName;
    tableData{rowIdx,4}=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');

    myData.MainTabVarTableData=tableData;

    source.UserData=myData;


    H.refresh;

    H.selectTableRow('VariantsTable',rowIdx-1);

    isExpressionMode=strcmp(selVar,'expression');
    if isExpressionMode

        H.setEnabled('EditButton',true);
    end

end


function i_doOpen(H,~)

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.MainTabVarTableData;

    row=H.getSelectedTableRow('VariantsTable');
    if(row<0)
        return;
    end


    handle=tableData{row+1,1};
    validHandle=false;
    try %#ok
        get_param(handle,'Name');
        validHandle=true;
    end

    if validHandle
        open_system(handle,'force');
    else
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('Simulink:dialog:SubsystemChoiceNotPresentInVariantSubsystem'),...
        'Error',true);
    end
end


function i_doEdit(H,block)

    source=H.getSource;
    myData=source.UserData;
    tableData=myData.MainTabVarTableData;

    row=H.getSelectedTableRow('VariantsTable');
    if(row<0)
        return;
    end


    object=tableData{row+1,3};
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
            tableData=myData.MainTabVarTableData;


            idxs=find(strcmp(tableData(:,3),name));
            if~isempty(idxs)
                for j=1:length(idxs)
                    tableData{idxs(j),4}=object.Condition;
                end
            end


            myData.MainTabVarTableData=tableData;
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


function i_doRefresh(H,block)

    source=H.getSource;

    if~isempty(block.VariantChoicesSpecifier)

        err='';
        try

            slInternal('SyncVASGraphWithExternalSource',block.getFullName);
            warningDisplayText='';
        catch ex
            warningDisplayText=subsysVariantsddg_cb('getWarningDisplayText',ex);
            if isempty(warningDisplayText)


                warningDisplayText='';
                err=ex;
            end
        end
        source.UserData.WarningDisplayText=warningDisplayText;
    end

    mainTabVarTableData=subsysVariantsddg_cb('getVariantsData',block.Handle);

    if~isempty(block.VariantChoicesSpecifier)
        if~isempty(warningDisplayText)||~isempty(err)

            H.setActiveTab('DialogTabs',1);
            refTabVarTableData=cell(0,2);
        else
            refTabVarTableData=i_getRefTabVarTableDataFromFilenames(mainTabVarTableData(:,2));
        end
        source.UserData.RefTabVarTableData=refTabVarTableData;

        if~isempty(err)
            H.refresh;
            err.throwAsCaller;
        end
    end

    myData=source.UserData;




    sel=H.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VariantControlMode=selVar;
    isExpressionMode=strcmp(selVar,'expression');
    if~isExpressionMode
        myData.MainTabVarTableData=mainTabVarTableData(:,1:3);

        H.setEnabled('EditButton',false);
        syncAllOpenDialogs(source,H,'EditButton','',false);
    else


        myData.MainTabVarTableData=mainTabVarTableData;

        rows=size(mainTabVarTableData,1);
        if(rows>0)
            varObject=strtrim(mainTabVarTableData{1,3});
            editEnabled=~isempty(varObject)&&isvarname(varObject);
        else
            editEnabled=false;
        end
        H.setEnabled('EditButton',editEnabled);
        syncAllOpenDialogs(source,H,'EditButton','',editEnabled);
    end


    source.UserData=myData;


    H.selectTableRow('VariantsTable',0);

    H.refresh;
end


function i_doClose(H)

    source=H.getSource;


    if isempty(DAStudio.ToolRoot.getOpenDialogs(H.getSource))
        source.UserData=[];
    end
end


function i_doOpenME(~)

    me=daexplr;
    ch=me.getRoot.getHierarchicalChildren;
    me.view(ch(1));
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


    val=H.getWidgetValue('VariantSubsysBlockAllowZeroConditionCheckbox');
    if val
        myData.AZVC='on';
    else
        myData.AZVC='off';
    end
    syncAllOpenDialogs(source,H,'VariantSubsysBlockAllowZeroConditionCheckbox',val,'');

    source.UserData=myData;

end


function i_doSetVariantActivationTime(H,~)




    source=H.getSource;
    myData=source.UserData;

    VATIdx=H.getWidgetValue('VariantActivationTimeCombo');
    entries=myData.VATypeEntries;
    selVar=entries{VATIdx+1};
    myData.VariantActivationTime=selVar;

    VCMode=myData.VariantControlMode;
    selVATDesc=Simulink.variant.ddgutils.getVariantModeDescription(VCMode,selVar);

    H.setWidgetValue('VC_VATDescription',selVATDesc);
    syncAllOpenDialogs(source,H,'VariantActivationTimeCombo',VATIdx,'');
    syncAllOpenDialogs(source,H,'VC_VATDescription',selVATDesc,'');
    source.UserData=myData;


end


function i_doVCType(H,block)

    source=H.getSource;
    myData=source.UserData;

    sel=H.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    myData.VariantControlMode=selVar;
    syncAllOpenDialogs(source,H,'VariantControlModeCombo',sel,'');

    isLabelVCMode=strcmp('label',selVar);
    isExpressionVCMode=~isLabelVCMode&&strcmp('expression',selVar);
    isSimCodegenVCMode=~isLabelVCMode&&~isExpressionVCMode...
    &&strcmp('sim codegen switching',selVar);

    H.setVisible('LabelGroup',isLabelVCMode);
    syncAllOpenDialogs(source,H,'LabelGroup','','',isLabelVCMode);

    H.setVisible('OverrideVariantCombo',isLabelVCMode);
    syncAllOpenDialogs(source,H,'OverrideVariantCombo','','',isLabelVCMode);

    propCondEnabled=Simulink.isParameterEnabled(block.Handle,'PropagateVariantConditions');
    H.setEnabled('PropagateConditionsCheckbox',propCondEnabled);
    syncAllOpenDialogs(source,H,'PropagateConditionsCheckbox','',propCondEnabled,true);

    H.setVisible('VariantSubsysBlockAllowZeroConditionCheckbox',isExpressionVCMode);
    azvcCanBeEnabled=Simulink.isParameterEnabled(block.Handle,'AllowZeroVariantControls');
    H.setEnabled('VariantSubsysBlockAllowZeroConditionCheckbox',isExpressionVCMode&&azvcCanBeEnabled);
    syncAllOpenDialogs(source,H,'VariantSubsysBlockAllowZeroConditionCheckbox','',isExpressionVCMode&&azvcCanBeEnabled,isExpressionVCMode);

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


function[success,err]=i_doPreApply(H,block)

    err='';success=true;

    source=H.getSource;


    warnstate=warning;
    warning('off','Simulink:Commands:SetParamLinkChangeWarn');

    if slfeature('VariantAssemblySubsystem')>0&&H.isEnabled('ChoiceSelectorEdit')
        variantChoicesSpecifier=H.getWidgetValue('ChoiceSelectorEdit');
        try
            i_ErrorOutIfVariantChoicesSpecifierIsEmpty(variantChoicesSpecifier);

            disableUIElementsAndEnableValidatingText(H);
            slInternal('SetParamVariantChoicesSpecifierWithError',block.getFullName,variantChoicesSpecifier);

            mainTabVarTableData=subsysVariantsddg_cb('getVariantsData',block.Handle);
            source.UserData.MainTabVarTableData=mainTabVarTableData;
            source.UserData.Entries=mainTabVarTableData(:,2);

            warningDisplayText='';
        catch ex
            warningDisplayText=i_getWarningDisplayText(ex);
            mainTabVarTableData=cell(0,2);

            if isempty(warningDisplayText)

                success=false;
                err=i_getErrMsgToDisplayInDialog(ex);
            end
        end
        i_updateVASUserData(source,variantChoicesSpecifier,...
        i_getRefTabVarTableDataFromFilenames(mainTabVarTableData(:,2)),warningDisplayText);
    end



    myData=source.UserData;
    data=myData.MainTabVarTableData;
    varCtrlChanged=myData.TableItemChanged;
    blockH=block.Handle;

    try

        oldGpcVal=get_param(blockH,'GeneratePreprocessorConditionals');
        oldPropVal=get_param(block.Handle,'PropagateVariantConditions');
        oldAZVCVal=get_param(block.Handle,'AllowZeroVariantControls');
        oldLabelVal=block.LabelModeActiveChoice;
        oldVCMVal=block.VariantControlMode;
        oldVATVal=block.VariantActivationTime;


        valProp=H.getWidgetValue('PropagateConditionsCheckbox');

        if(valProp~=strcmp(oldPropVal,'on'))
            if valProp
                set_param(block.Handle,'PropagateVariantConditions','on');
            else
                set_param(block.Handle,'PropagateVariantConditions','off');
            end
        end


        if H.isEnabled('VariantSubsysBlockAllowZeroConditionCheckbox')
            valAZVC=H.getWidgetValue('VariantSubsysBlockAllowZeroConditionCheckbox');
            if valAZVC~=strcmp(oldAZVCVal,'on')
                if valAZVC
                    set_param(block.Handle,'AllowZeroVariantControls','on');
                else
                    set_param(block.Handle,'AllowZeroVariantControls','off');
                end
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
            selected=H.getWidgetValue('VariantActivationTimeCombo');
            VATypeEntries=myData.VATypeEntries;
            selVATVal=VATypeEntries{selected+1};
            block.VariantActivationTime=selVATVal;
        end



        if(varCtrlChanged)
            considerThisBlock=true;
            parentH=slInternal('getTopMostLinkedOrConfiguredParent',blockH,considerThisBlock);
            if(ishandle(parentH))
                allowChanges=slInternal('showLinkDataWarningDialog',parentH,blockH);
                if allowChanges

                end
            end
        end

        if(varCtrlChanged)
            rows=size(data,1);

            for i=1:rows
                blk=data{i,1};
                set_param(blk,'VariantControl',data{i,3});
            end
        end

        if H.isEnabled('OverrideVariantCombo')
            sel=H.getWidgetValue('OverrideVariantCombo');
            entries=myData.Entries;
            if~isempty(entries)




                if sel==-1
                    assert(~isempty(myData.ChoiceSelector))
                    sel=0;
                end
                labelVal=entries{sel+1};
            else
                labelVal='';
            end
            block.LabelModeActiveChoice=labelVal;
        end


    catch ex
        err=Simulink.internal.vmgr.VMUtils.getMsgStrWithCauses(ex);
        success=false;
        if H.isEnabled('GeneratePreprocessorCheckbox')
            set_param(blockH,'GeneratePreprocessorConditionals',oldGpcVal);
        end
        if H.isEnabled('PropagateConditionsCheckbox')
            set_param(blockH,'PropagateVariantConditions',oldPropVal);
        end
        if H.isEnabled('VariantSubsysBlockAllowZeroConditionCheckbox')
            set_param(blockH,'AllowZeroVariantControls',oldAZVCVal);
        end
        if H.isEnabled('OverrideVariantCombo')
            block.LabelModeActiveChoice=oldLabelVal;
        end
        if H.isVisible('VariantControlModeCombo')
            block.VariantControlMode=oldVCMVal;
        end
        if H.isEnabled('VariantActivationTimeCombo')
            block.VariantActivationTime=oldVATVal;
        end

    end




    warning(warnstate);


    H.refresh;

end



function tableData=i_GetVariantsData(h)

    info=get_param(h,'Variants');




    rows=length(info);



    tableData=cell(rows,4);

    mdl=get_param(bdroot(h),'Name');

    for i=1:rows


        bH=get_param(info(i).BlockName,'Handle');


        tableData{i,1}=bH;


        blkName=get_param(bH,'Name');
        blkName=strrep(blkName,newline,' ');
        tableData{i,2}=blkName;


        varControlName=info(i).Name;
        tableData{i,3}=varControlName;
        if Simulink.variant.keywords.isValidVariantKeyword(varControlName)
            isVariantObject=false;
        else
            isVariantObject=slprivate('isVariantControlVariantObject',bH,varControlName);
        end
        if isempty(varControlName)||varControlName(1)=='%'
            condValue=DAStudio.message('Simulink:Variants:Ignored');
        else
            condValue=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');
        end


        if isVariantObject
            try
                condValue=evalinGlobalScope(mdl,[varControlName,'.Condition']);
            catch
                condValue=DAStudio.message('Simulink:dialog:NoVariantObject');
            end
        end

        tableData{i,4}=condValue;
    end
end





