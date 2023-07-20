function[ResultDescription]=checkLogicBlockUseNonBooleanOutput(system)



    ResultDescription={};


    hScope=get_param(system,'Handle');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    [currentResult,found]=getLogicBlockUseNonBooleanOutput(hScope,mdladvObj);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message('ModelAdvisor:engine:TitletipIdentLogicBlockUseNonBooleanOutput'));
    ft.setSubBar(0);

    if~isempty(currentResult)

        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:LogicBlockName'),...
        DAStudio.message('ModelAdvisor:engine:LogicBlockCurSetting'),...
        DAStudio.message('ModelAdvisor:engine:LogicBlockNewSetting')});

        info={};

        for n=1:length(currentResult)
            blk=currentResult{n};


            expVal='boolean';

            paramVal=get_param(blk,'OutDataTypeStr');
            info=[info;{blk,paramVal,expVal}];%#ok<AGROW>
        end

        ft.setTableInfo(info);
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ChangeLogicBlockUseNonBooleanOutputInfo'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:engine:ChangeLogicBlockUseNonBooleanOutputAction'));
        ResultDescription{end+1}=ft;

        myLVParam=ModelAdvisor.ListViewParameter;
        myLVParam.Name=DAStudio.message('ModelAdvisor:engine:TitleIdentLogicBlockUseNonBooleanOutput');
        blk_handle=zeros(1,length(currentResult));
        for i=1:length(currentResult)
            blk_handle(i)=currentResult{i};
        end
        myLVParam.Data=get_param(blk_handle,'object')';
        myLVParam.Attributes={'OutDataTypeStr'};

        mdladvObj.setListViewParameters({myLVParam});
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    else
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        ft.setSubResultStatus('Pass');
        if(found)
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ChangeLogicBlockUseNonBooleanOutputPass'));
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:NoLogicBlockFound'));
        end
        ResultDescription{end+1}=ft;
    end

