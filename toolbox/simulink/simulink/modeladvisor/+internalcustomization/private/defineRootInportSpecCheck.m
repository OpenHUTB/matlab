


function rec=defineRootInportSpecCheck








    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckRootInport');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckRootInport');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleCheckRootInport';
    rec.CallbackHandle=@ExecCheckRootInports;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=true;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.TitleID='mathworks.design.RootInportSpec';
    rec.SupportExclusion=true;






    function[ResultDescription,ResultHandles]=ExecCheckRootInports(system)




        ResultDescription={};
        ResultHandles={};


        passString=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
        model=bdroot(system);
        hScope=get_param(system,'Handle');
        cs=getActiveConfigSet(model);
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);


        if hScope~=get_param(model,'handle')
            currentDescription=DAStudio.message('ModelAdvisor:engine:CheckRootInportsScope');
            currentResult={};
            mdladvObj.setCheckResultStatus(false);
        else
            hInports=find_system(hScope,'SearchDepth',1,'BlockType','Inport');



            hFcnCallInports=unique(find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'OutputFunctionCall','on'));
            hInports=setdiff(hInports,hFcnCallInports);
            functionCallTrigger=find_system(bdroot(system),'SearchDepth',1,'BlockType','TriggerPort','TriggerType','function-call');

            hUnsetPorts=[...
            find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'PortDimensions','-1');...
            find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'OutDataTypeStr','Inherit: auto');...


            ];

            if strcmp(get_param(cs,'SolverType'),'Variable-step')||...
                (strcmp(get_param(cs,'SolverType'),'Fixed-step')&&...
                ~strcmp(get_param(cs,'SampleTimeConstraint'),'STIndependent')&&...
                isempty(hFcnCallInports)&&isempty(functionCallTrigger))



                hUnsetPorts=[hUnsetPorts;...
                find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SampleTime','-1')];
            end
            hUnsetPorts=unique(hUnsetPorts);



            currentResult=hUnsetPorts;

            currentResult=mdladvObj.filterResultWithExclusion(currentResult);
            if~isempty(currentResult)
                currentDescription=DAStudio.message('ModelAdvisor:engine:CheckRootInportsWarn');
                mdladvObj.setCheckResultStatus(false);
            else
                currentDescription=passString;
                mdladvObj.setCheckResultStatus(true);
            end
        end
        ResultDescription{end+1}=currentDescription;
        ResultHandles{end+1}=currentResult;
