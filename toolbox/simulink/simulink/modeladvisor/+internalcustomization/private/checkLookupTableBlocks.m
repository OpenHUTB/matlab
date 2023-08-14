function[ResultDescription]=checkLookupTableBlocks(system)



    ResultDescription={};


    hScope=get_param(system,'Handle');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    currentResult=getLookupTableBlocks(hScope);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message('Simulink:tools:MATitletipIdentLUTRangeCheckCode'));
    ft.setSubBar(0);

    if~isempty(currentResult)

        ft.setColTitles({DAStudio.message('Simulink:tools:MALookupTableBlockName'),...
        DAStudio.message('Simulink:tools:MALookupTableParamName'),...
        DAStudio.message('Simulink:tools:MALookupTableNewSetting')});

        info={};

        for n=1:length(currentResult)
            blk=currentResult{n};
            dlgParList=get_param(blk,'IntrinsicDialogParameters');
            expVal='on';
            if strcmp(get_param(blk,'BlockType'),'Interpolation_n-D')
                paramPrompt=strtrim(dlgParList.RemoveProtectionIndex.Prompt);
            else
                paramPrompt=strtrim(dlgParList.RemoveProtectionInput.Prompt);
            end
            info=[info;{blk,paramPrompt,expVal}];%#ok<AGROW>
        end

        ft.setTableInfo(info);
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MALookupTableRemoveRangeCheckingCodeInfo'));
        ft.setRecAction(DAStudio.message('Simulink:tools:MALookupTableRangeRemoveAction',DAStudio.message('Simulink:tools:MALookupTableRangeRemove')));
        ResultDescription{end+1}=ft;

        myLVParam=ModelAdvisor.ListViewParameter;
        myLVParam.Name=DAStudio.message('Simulink:tools:MATitleIdentLUTRangeCheckCode');
        blk_handle=zeros(1,length(currentResult));
        for i=1:length(currentResult)
            blk_handle(i)=currentResult{i};
        end
        myLVParam.Data=get_param(blk_handle,'object')';
        myLVParam.Attributes={'RemoveProtectionInput','RemoveProtectionIndex'};

        mdladvObj.setListViewParameters({myLVParam});
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    else
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MALUTRemoveRangeCheckCodePass'));
        ResultDescription{end+1}=ft;
    end

