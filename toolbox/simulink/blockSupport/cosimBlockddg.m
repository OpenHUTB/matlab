function dlgStruct=cosimBlockddg(source,h,varargin)





    if nargin>2
        isSlimDialog=varargin{1};
    else
        isSlimDialog=false;
    end

    disableWholeDialog=source.isHierarchyReadonly;

    if~disableWholeDialog
        [~,isLocked]=source.isLibraryBlock(h);
        disableWholeDialog=isLocked;
    end


    paramGrp=i_GetParamGroup(source,h,disableWholeDialog,isSlimDialog);




    dlgStruct.DialogTag='cosimblk';
    if isSlimDialog
        dlgStruct.Items=paramGrp.Items;
        dlgStruct.DialogMode='Slim';
    else
        dlgStruct.DialogTitle=DAStudio.message('CoSimService:Blocks:CRCSDialogTitle');
        descGrp=i_GetDescGroup(source,h);
        dlgStruct.Items={descGrp,paramGrp};
        dlgStruct.LayoutGrid=[2,1];
        dlgStruct.RowStretch=[0,1];
    end


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    if~isSlimDialog

        dlgStruct.PreApplyCallback='cosimBlockddg_cb';
        dlgStruct.PreApplyArgs={'doPreApply','%dialog'};
        dlgStruct.CloseCallback='cosimBlockddg_cb';
        dlgStruct.CloseArgs={'doClose','%dialog'};
    end


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.DisableDialog=disableWholeDialog;
    dlgStruct.DefaultOk=false;


    blockPath=gcbp;
    if(blockPath.getLength()==0)
        lastBlock='';
    else
        lastBlock=blockPath.getBlock(blockPath.getLength());
    end
    block=h.getFullName();




    if(strcmp(lastBlock,block))
        source.UserData.gcbp=blockPath;
    else
        source.UserData.gcbp=Simulink.BlockPath({block});
    end
end




function descGrp=i_GetDescGroup(~,h)
    descTxt.Name=DAStudio.message('CoSimService:Blocks:CRCSBlockDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;
    descTxt.Tag='CoSimServiceBlockDescription';

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];
end




function paramGrp=i_GetParamGroup(source,h,disableWholeDialog,isSlimDialog)

    source.UserData.DisableWholeDialog=disableWholeDialog;
    parentHandle=get_param(get_param(h.Handle,'Parent'),'Handle');
    isVSSChoiceBlock=slInternal('isVariantSubsystem',parentHandle);
    source.UserData.IsVSSChoiceBlock=isVSSChoiceBlock;



    mainTab.Name=DAStudio.message('Simulink:dialog:Main');
    mainTab.Items={i_GetMainPanel(source,h,isSlimDialog)};
    if isSlimDialog
        paramTabs=mainTab;
    else
        paramTabs.Tag='ParamGroup';
        paramTabs.Type='tab';
        paramTabs.RowSpan=[2,2];
        paramTabs.ColSpan=[1,1];
        paramTabs.Source=h;
        paramTabs.Visible=true;
        paramTabs.Tabs={};
        paramTabs.Tabs{end+1}=mainTab;

        instParamTab=cosimBlockddg_InstParamTab(source,isSlimDialog);
        paramTabs.Tabs{end+1}=instParamTab.getInstParamTab();
    end

    paramGrp.Type='group';
    paramGrp.LayoutGrid=[1,1];
    if isSlimDialog
        paramGrp.Items=paramTabs.Items{1}.Items;
        paramGrp.Items{1}.Source=h;
    else
        paramTabs.Visible=true;
        paramGrp.Items={paramTabs};
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
        paramGrp.Source=h;
    end
end

function mainPanel=i_GetMainPanel(source,h,isSlimDialog)

    propName='CosimulationTargetNameDialog';
    cosimTarget.ObjectProperty=propName;
    cosimTarget.Tag=propName;
    cosimTarget.Name=DAStudio.message('CoSimService:Blocks:CRCSTargetName');
    cosimTarget.Type='edit';
    cosimTarget.MatlabMethod='handleEditEvent';
    cosimTarget.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimTarget.NameLocation=2;
    cosimTarget.RowSpan=[1,1];
    cosimTarget.ColSpan=[1,1];
    cosimTarget.Enabled=cosimBlockddg_cb('EnableTargetName',source,h);

    cosimTargetBrowse.Name=DAStudio.message('Simulink:dialog:WorkspaceFileBrowserButtonName');
    cosimTargetBrowse.Alignment=10;
    cosimTargetBrowse.Type='pushbutton';
    cosimTargetBrowse.RowSpan=[1,1];
    cosimTargetBrowse.ColSpan=[2,2];
    cosimTargetBrowse.Enabled=cosimBlockddg_cb('EnableBrowse',h);
    cosimTargetBrowse.Tag='TargetBrowse';
    cosimTargetBrowse.MatlabMethod='cosimBlockddg_cb';
    cosimTargetBrowse.MatlabArgs={'doBrowse','%dialog',propName};

    cosimTargetOpen.Name=DAStudio.message('CoSimService:Blocks:CRCSOpenTargetFile');
    cosimTargetOpen.Alignment=10;
    cosimTargetOpen.Type='pushbutton';
    cosimTargetOpen.RowSpan=[1,1];
    cosimTargetOpen.ColSpan=[3,3];
    cosimTargetOpen.Enabled=cosimBlockddg_cb('EnableOpen',h);
    cosimTargetOpen.Tag='TargetOpen';
    cosimTargetOpen.MatlabMethod='cosimBlockddg_cb';
    cosimTargetOpen.MatlabArgs={'doOpen','%dialog'};


    if isSlimDialog
        rowIdx=1;

        cosimMainPanel.Type='togglepanel';
        cosimMainPanel.Name=DAStudio.message('Simulink:dialog:Main');
        cosimMainPanel.RowSpan=[1,1];
        cosimMainPanel.ColSpan=[1,2];
        cosimMainPanel.Expand=1;
        cosimMainPanel.Tag='Main_togglepanel';

        [cosimTargetLabel,cosimTarget]=convertWidgetToSlim(cosimTarget);


        rowIdx=rowIdx+1;
        cosimButtonPanel.Name='';
        cosimButtonPanel.Type='panel';
        cosimButtonPanel.LayoutGrid=[1,3];
        cosimButtonPanel.RowSpan=[rowIdx,rowIdx];
        cosimButtonPanel.ColSpan=[1,2];
        cosimButtonPanel.ColStretch=[1,0,0];

        buttonspacer.Name='';
        buttonspacer.Type='text';
        buttonspacer.RowSpan=[1,1];
        buttonspacer.ColSpan=[1,1];

        cosimButtonPanel.Items={buttonspacer,cosimTargetOpen,cosimTargetBrowse};
        tmpItems={cosimTargetLabel,cosimTarget,cosimButtonPanel};
    else
        rowIdx=1;
        cosimTargetPanel.Name='';
        cosimTargetPanel.Type='panel';
        cosimTargetPanel.LayoutGrid=[1,3];
        cosimTargetPanel.RowSpan=[1,1];
        cosimTargetPanel.ColStretch=[1,0,0];
        cosimTargetPanel.Items={cosimTarget,cosimTargetBrowse,cosimTargetOpen};
        tmpItems={cosimTargetPanel};
    end


    rowIdx=rowIdx+1;
    propName='CosimulationDebugMode';
    cosimDF.ObjectProperty=propName;
    cosimDF.Tag=propName;
    cosimDF.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSDebug');
    cosimDF.Type='checkbox';
    cosimDF.DialogRefresh=true;
    cosimDF.Enabled=1;
    cosimSM.MatlabMethod='handleCheckEvent';
    cosimSM.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimDF.RowSpan=[rowIdx,rowIdx];
    cosimDF.ColSpan=[1,3];
    tmpItems=[tmpItems,cosimDF];




    rowIdx=rowIdx+1;
    propName='CosimulationSimMode';
    cosimSM.ObjectProperty=propName;
    cosimSM.Tag=propName;
    cosimSM.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefSimulationMode');
    cosimSM.Type='combobox';
    cosimSM.Entries={'Normal','Accelerator'};
    cosimSM.Editable=1;
    cosimSM.MatlabMethod='handleEditEvent';
    cosimSM.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimSM.RowSpan=[rowIdx,rowIdx];
    cosimSM.ColSpan=[1,2];
    tmpItems=[tmpItems,cosimSM];


    rowIdx=rowIdx+1;
    propName='CosimulationSampleTime';
    cosimST.ObjectProperty=propName;
    cosimST.Tag=propName;
    cosimST.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSSampleTime');
    cosimST.Type='edit';
    cosimST.MatlabMethod='handleEditEvent';
    cosimST.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimST.RowSpan=[rowIdx,rowIdx];
    cosimST.ColSpan=[1,2];
    tmpItems=[tmpItems,cosimST];


    rowIdx=rowIdx+1;
    list=Simulink.CoSimServiceUtils.listInstalledMatlabs;
    listCell={'Default',list.MatlabRelease};
    propName='CosimulationRelease';
    cosimRM.ObjectProperty=propName;
    cosimRM.Tag=propName;
    cosimRM.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSRelease');
    cosimRM.Type='combobox';
    cosimRM.Entries=listCell;
    cosimRM.Editable=1;
    cosimRM.MatlabMethod='handleEditEvent';
    cosimRM.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};

    cosimRMBtn.Type='pushbutton';
    cosimRMBtn.Tag='CosimRMBtn';
    cosimRMBtn.ToolTip=DAStudio.message('Simulink:dialog:ModelRefCRCSOpenReleaseManager');
    cosimRMBtn.FilePath=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Open_16.png');
    cosimRMBtn.RowSpan=[1,1];
    cosimRMBtn.ColSpan=[3,3];
    cosimRMBtn.MatlabMethod='multivercosim.internal.startUI';

    cosimRMPanel.Type='panel';
    cosimRMPanel.Items={cosimRM,cosimRMBtn};
    cosimRMPanel.LayoutGrid=[1,2];
    cosimRMPanel.RowSpan=[rowIdx,rowIdx];
    cosimRMPanel.ColSpan=[1,3];
    tmpItems=[tmpItems,cosimRMPanel];


    verStr='';
    try
        crcsRel=get_param(h.Handle,'CosimulationRelease');
        crcsIsDefault=strcmp(crcsRel,'Default');
        if crcsIsDefault
            targetFile=get_param(h.Handle,'CosimulationTargetFile');
            if~isempty(targetFile)&&isfile(targetFile)

                targetInfo=Simulink.MDLInfo(targetFile);
                crcsRel=Simulink.CoSimServiceUtils.getDefaultMatlabVersion(targetInfo.ReleaseName);
            else
                crcsRel='';
            end
        end
        if~isempty(crcsRel)
            relIdx=find(strcmp({list.MatlabRelease},crcsRel));
            if~isempty(relIdx)
                verStr=[list(relIdx).MatlabVersion];
                if crcsIsDefault
                    verStr=[verStr,' (',crcsRel,')'];
                end
            else
                verStr='';
            end
        end
    catch
        verStr='';
    end

    if~isempty(verStr)
        rowIdx=rowIdx+1;
        cosimVer.Name=[DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSVersion'),' ',verStr];
        cosimVer.Type='text';
        cosimVer.RowSpan=[rowIdx,rowIdx];
        cosimVer.ColSpan=[1,1];
        cosimVer.Tag='cosimVersion';
        tmpItems=[tmpItems,cosimVer];
    end


    rowIdx=rowIdx+1;
    propName='CosimulationSetupScript';
    cosimSS.ObjectProperty=propName;
    cosimSS.Tag=propName;
    cosimSS.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSSetupScript');
    cosimSS.Type='edit';
    cosimSS.MatlabMethod='handleEditEvent';
    cosimSS.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimSS.RowSpan=[rowIdx,rowIdx];
    cosimSS.ColSpan=[1,3];
    tmpItems=[tmpItems,cosimSS];


    rowIdx=rowIdx+1;
    propName='CosimulationCleanupScript';
    cosimCS.ObjectProperty=propName;
    cosimCS.Tag=propName;
    cosimCS.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefCRCSCleanupScript');
    cosimCS.Type='edit';
    cosimCS.MatlabMethod='handleEditEvent';
    cosimCS.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    cosimCS.RowSpan=[rowIdx,rowIdx];
    cosimCS.ColSpan=[1,3];
    tmpItems=[tmpItems,cosimCS];

    if isSlimDialog

        numItemsInMainPanel=rowIdx;
        rowIdx=0;


        cosimMainPanel.LayoutGrid=[numItemsInMainPanel,2];
        cosimMainPanel.RowStretch=[zeros(1,numItemsInMainPanel-1),1];
        cosimMainPanel.ColStretch=[4,5];
        cosimMainPanel.Items=tmpItems;

        tmpItems={};
    end

    addSpacer=~isSlimDialog;

    if isSlimDialog

        rowIdx=2;
        cosimArgsPanel.Type='togglepanel';
        cosimArgsPanel.Tag='InstParam_togglepanel';
        cosimArgsPanel.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelParametersToggle');
        cosimArgsPanel.RowSpan=[rowIdx,rowIdx+1];
        cosimArgsPanel.ColSpan=[1,2];
        cosimArgsPanel.Expand=0;
        cosimArgsPanel.LayoutGrid=[1,1];


        instParamTab=cosimBlockddg_InstParamTab(source,isSlimDialog);
        argsWidget=instParamTab.getInstParamTab();
        argsItems=argsWidget.Items{1}.Items;


        addSpacer=argsItems{1}.Visible;
        cosimArgsPanel.Items=argsItems;

        rowIdx=rowIdx+1;
    end

    if addSpacer
        rowIdx=rowIdx+1;
        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
    end

    if isSlimDialog
        tmpItems={cosimMainPanel,cosimArgsPanel};
    end


    numCols=3;
    if isSlimDialog
        numCols=2;
    end
    paramPanel.Type='panel';
    paramPanel.LayoutGrid=[rowIdx,numCols];
    paramPanel.RowSpan=[1,1];
    paramPanel.ColSpan=[1,1];
    paramPanel.RowStretch=[zeros(1,rowIdx-1),1];
    paramPanel.Items=tmpItems;

    mainPanel.Type='panel';
    mainPanel.Items={paramPanel};
end
