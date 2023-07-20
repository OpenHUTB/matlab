function styleguide_na_0004()









    rec=ModelAdvisor.Check('mathworks.maab.na_0004');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na0004Title');
    rec.setCallbackFcn(@na_0004_StyleOneCallback,'None','StyleOne');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:na_0004_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:na0004Tip')];
    rec.Value=true;
    rec.setLicense({styleguide_license});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na0004Title';
    rec.SupportExclusion=true;

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@action_na_0004);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:styleguide:na0004ActionDescription');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function[ResultDescription]=na_0004_StyleOneCallback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};



    actionResultData=[];

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Information'));
    ResultDescription{end+1}=ft;


    result=true;

    if(sLSGIsModelReference(system)==true)

    else

        deviantSystems={};%#ok<NASGU>







        checkResultData.parametersToCheck...
        ={'WideLines'...
        ,'EditorStatusBar'...
        ,'EditorToolbars'...
        ,'ShowViewerIcons'...
        ,'ShowTestPointIcons'...
        ,'ShowPortDataTypes'...
        ,'ShowStorageClass'...
        ,'ShowLineDimensions'...
        ,'ModelBrowserVisibility'...
        ,'ExecutionOrderLegendDisplay'...
        ,'ShowModelReferenceBlockVersion'...
        ,'ShowModelReferenceBlockIO'...
        ,'SampleTimeColors'...
        ,'LibraryLinkDisplay'...
        ,'ShowLinearizationAnnotations'...
        };

        checkResultData.parameterTargetValues...
        ={'on'...
        ,'on'...
        ,'on'...
        ,'on'...
        ,'on'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'off'...
        ,'none'...
        ,'on'...
        };

        parameterfailureOutputs={...
        DAStudio.message('ModelAdvisor:styleguide:na0004WideVectorLinesFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004StatusBarFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004ToolbarFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004ViewerIconFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004TestPointIconFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004PortTypeFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004StorageClassFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004LineDimensionFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004ModelBrowserFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004SortedOrderFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004ModelVersionFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004ModelReferenceBlockIOFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004SampleTimeColorsFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004LibraryLinkDisplayFailMsg'),...
        DAStudio.message('ModelAdvisor:styleguide:na0004LinearizationAnnotationsFailMsg'),...
        };


        checkResultData.parameterValues=cell(1,length(checkResultData.parametersToCheck));


        slRoot=slroot;




        for parameterIndex=1:(length(checkResultData.parametersToCheck))









            if any(strcmp({'EditorToolbars','EditorStatusBar'},...
                checkResultData.parametersToCheck{parameterIndex}))
                checkResultData.parameterValues{parameterIndex}=slRoot.(checkResultData.parametersToCheck{parameterIndex});
            else
                checkResultData.parameterValues{parameterIndex}=get_param((bdroot(system)),...
                (checkResultData.parametersToCheck{parameterIndex}));
            end
        end




        parameterComparisonResults=strcmp(checkResultData.parameterValues,...
        checkResultData.parameterTargetValues);


        ft1=ModelAdvisor.FormatTemplate('TableTemplate');
        ft1.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck1'));
        ft1.setInformation({DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck1_Info')});
        ft1.setSubResultStatus({'pass'});
        ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck1_Pass'));
        if~all(parameterComparisonResults)
            ft1.setSubResultStatus({'warn'});
            if(strcmp(system,bdroot(system))==true)


                ft1.setSubResultStatusText(DAStudio.message...
                ('ModelAdvisor:styleguide:na0004ModelSettingsDescMsg'));
            else



                ft1.setSubResultStatusText({[DAStudio.message('ModelAdvisor:styleguide:na0004AbnormalContextMsg'),DAStudio.message('ModelAdvisor:styleguide:na0004ModelSettingsDescMsg')]});
            end


            actionResultData.DisplayParameters.Names=checkResultData.parametersToCheck(~parameterComparisonResults);
            actionResultData.DisplayParameters.TargetValues=checkResultData.parameterTargetValues(~parameterComparisonResults);


            ft1.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na0004Col_1'),...
            DAStudio.message('ModelAdvisor:styleguide:na0004Col_2'),...
            DAStudio.message('ModelAdvisor:styleguide:na0004Col_3')});

            for inx=1:length(checkResultData.parametersToCheck)
                if(parameterComparisonResults(inx)==0)



                    ft1.addRow({parameterfailureOutputs{inx},...
                    DAStudio.message(['ModelAdvisor:styleguide:na0004ParamValue_',checkResultData.parameterTargetValues{inx}]),...
                    DAStudio.message(['ModelAdvisor:styleguide:na0004ParamValue_',checkResultData.parameterValues{inx}])});
                end
            end
            ft1.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_1_RecAct'));
            result=false;
        end
        ResultDescription{end+1}=ft1;


        deviantSystems={};%#ok<NASGU>


        blks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'Type','block');





        SFblks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'Type','block',...
        'MaskType','Stateflow');

        if~isempty(SFblks)
            blks=setprune(blks,SFblks,'all');
        end




        SystemRequirementItemSubsystems=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'Type','block',...
        'BlockType','SubSystem',...
        'MaskType','System Requirement Item');
        blks=setdiff(blks,SystemRequirementItemSubsystems);



        isDirtyFlag=get_param(bdroot(system),'Dirty');

        sampleColorsSetting=get_param(bdroot(system),'SampleTimeColors');
        set_param(bdroot(system),'SampleTimeColors','off');


        set_param(system,'HiliteAncestors','none');




        busElemBlks=find_system(system,'FollowLinks',followlinkParam.Value,'LookUnderMasks',lookundermaskParam.Value,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'Type','block','IsBusElementPort','on');

        whiteBusElemBlks=busElemBlks(strcmpi(get_param(busElemBlks,'BackgroundColor'),'white'));
        blackBusElemBlks=busElemBlks(strcmpi(get_param(busElemBlks,'BackgroundColor'),'black'));
        blks=setdiff(blks,whiteBusElemBlks);
        blks=setdiff(blks,blackBusElemBlks);

        backColor=~strcmp(get_param(blks,'BackgroundColor'),'white');
        foreColor=~strcmp(get_param(blks,'ForegroundColor'),'black');




        set_param(bdroot(system),'SampleTimeColors',sampleColorsSetting);


        set_param(bdroot(system),'Dirty',isDirtyFlag);

        badColors=backColor|foreColor;

        deviantSystems=blks(badColors);


        deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);

        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft2.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck2_Colors'));
        ft2.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck2_Colors_Info'));
        ft2.setSubResultStatus({'pass'});
        ft2.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck2_Pass'));

        if~isempty(deviantSystems)
            ft2.setSubResultStatus({'warn'});

            ft2.setListObj(deviantSystems);
            ft2.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004BlockColorFailMsg'));
            ft2.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_2_RecAct'));
            result=false;


            actionResultData.ForgroundColorBlocks=blks(foreColor);
            actionResultData.BackgroundColorBlocks=blks(backColor);
        end
        ResultDescription{end+1}=ft2;


        deviantSystems={};%#ok<NASGU>












        checkResultData={};
        checkResultData.targetScreenColor='white';











        deviantSystems=sLSGGetDeviantSystemsAndSubsystems(system,...
        'ScreenColor',...
checkResultData...
        .targetScreenColor,followlinkParam.Value,lookundermaskParam.Value);

        ft3=ModelAdvisor.FormatTemplate('ListTemplate');
        ft3.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_3_Bkg_Colors'));
        ft3.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_3_Bkg_Colors_Info'));
        ft3.setSubResultStatus({'pass'});
        ft3.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_3_Pass'));


        deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);

        if~isempty(deviantSystems)


            ft3.setSubResultStatus({'warn'});

            ft3.setListObj(deviantSystems);
            ft3.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004ScreenColorFailMsg'));
            ft3.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_3_RecAct'));
            result=false;


            actionResultData.CanvasColorSystems=deviantSystems;
        end
        ResultDescription{end+1}=ft3;


        deviantSystems={};%#ok<NASGU>
        checkResultData={};
        checkResultData.targetZoomFactor='100';

deviantSystems...
        =sLSGGetDeviantSystemsAndSubsystems(system,...
        'ZoomFactor',...
        checkResultData.targetZoomFactor,followlinkParam.Value,lookundermaskParam.Value);






        violatingEditors={};
        violatingEditorObjs={};
        allstudios=DAS.Studio.getAllStudios();
        graphHandle=get_param(system,'handle');


        graphHID=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(graphHandle);

        for i=1:length(allstudios)
            studio=allstudios{i};
            editors=studio.App.getAllEditors();
            for editor=editors
                if isa(editor.getDiagram(),'SLM3I.Diagram')

                    editorHandle=editor.getDiagram.handle;
                    if editorHandle==graphHandle&&...
                        editor.getCanvas.Scale~=1
                        violatingEditors{end+1}=editor.getName;%#ok<AGROW>
                        violatingEditorObjs{end+1}=editor;%#ok<AGROW>
                    else
                        if GLUE2.HierarchyService.isAncestorOf(graphHID,editor.getHierarchyId())&&...
                            editor.getCanvas.Scale~=1
                            violatingEditors{end+1}=editor.getName;%#ok<AGROW>
                            violatingEditorObjs{end+1}=editor;%#ok<AGROW>
                        end
                    end
                end
            end
        end



        deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);
        ft4=ModelAdvisor.FormatTemplate('ListTemplate');
        ft4.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_4_Zoom'));
        ft4.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_4_Zoom_Info'));

        ft4.setSubResultStatus({'pass'});
        ft4.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_4_Pass'));

        if~(isempty(deviantSystems)&&isempty(violatingEditors))

            ft4.setSubResultStatus({'warn'});
            ft4.setListObj(union(deviantSystems,violatingEditors));
            ft4.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na0004SubCheck_4_RecAct'));
            ft4.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na0004ZoomFactorFailMsg'));
            result=false;



            actionResultData.ZoomSystems=deviantSystems;
            actionResultData.ZoomEditors=violatingEditorObjs;
        end
        ft4.setSubBar(0);
        ResultDescription{end+1}=ft4;
    end



    if result


        modelAdvisorObject.setCheckResultStatus(true);


    else
        modelAdvisorObject.setCheckResultStatus(false);
        modelAdvisorObject.setCheckResultData(actionResultData);
        modelAdvisorObject.setActionEnable(true);
    end

end

function result=action_na_0004(taskobj)
    result=ModelAdvisor.Paragraph;
    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    slRoot=slroot;


    ResultData=mdladvObj.getCheckResultData(taskobj.MAC);


    ft1=ModelAdvisor.FormatTemplate('ListTemplate');


    if isfield(ResultData,'DisplayParameters')

        ft1.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_1_InfoModified'));

        for n=1:length(ResultData.DisplayParameters.Names)
            if any(strcmp({'EditorToolbars','EditorStatusBar'},...
                ResultData.DisplayParameters.Names{n}))
                slRoot.(ResultData.DisplayParameters.Names{n})=ResultData.DisplayParameters.TargetValues{n};
            else
                set_param((bdroot(system)),ResultData.DisplayParameters.Names{n},ResultData.DisplayParameters.TargetValues{n});
            end
        end

        ft1.setListObj(ResultData.DisplayParameters.Names);
    else
        ft1.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_1_InfoNone'));
    end

    result.addItem(ft1.emitContent);


    ft2=ModelAdvisor.FormatTemplate('ListTemplate');




    if isfield(ResultData,'ForgroundColorBlocks')
        ft2.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_2_InfoModified'));
        for n=1:length(ResultData.ForgroundColorBlocks)
            set_param(ResultData.ForgroundColorBlocks{n},'foregroundColor','black');
        end
        for n=1:length(ResultData.BackgroundColorBlocks)
            set_param(ResultData.BackgroundColorBlocks{n},'backgroundColor','white');
        end

        ft2.setListObj(unique([ResultData.ForgroundColorBlocks;ResultData.BackgroundColorBlocks]));
    else
        ft2.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_2_InfoNone'));
    end
    result.addItem(ft2.emitContent);


    ft3=ModelAdvisor.FormatTemplate('ListTemplate');


    if isfield(ResultData,'CanvasColorSystems')
        ft3.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_3_InfoModified'));
        for n=1:length(ResultData.CanvasColorSystems)
            set_param(ResultData.CanvasColorSystems{n},'ScreenColor','white');
        end

        ft3.setListObj(ResultData.CanvasColorSystems);
    else
        ft3.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_3_InfoNone'));
    end
    result.addItem(ft3.emitContent);



    ft4=ModelAdvisor.FormatTemplate('ListTemplate');
    ft4.setSubBar(false);


    if isfield(ResultData,'ZoomSystems')||isfield(ResultData,'ZoomEditors')
        ft4.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_4_InfoModified'))

        modifiedSystems={};

        if isfield(ResultData,'ZoomEditors')
            for n=1:length(ResultData.ZoomEditors)
                editor=ResultData.ZoomEditors{n};
                if editor.isvalid()
                    editor.getCanvas.Scale=1;
                    modifiedSystems{end+1}=editor.getName;%#ok<AGROW>
                end
            end
        end

        if isfield(ResultData,'ZoomSystems')

            for n=1:length(ResultData.ZoomSystems)
                set_param(ResultData.ZoomSystems{n},'zoomFactor','100');
            end
            modifiedSystems=[modifiedSystems,ResultData.ZoomSystems];
        end

        ft4.setListObj(unique(modifiedSystems));
    else
        ft4.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0004Action_4_InfoNone'));
    end
    result.addItem(ft4.emitContent);

end
