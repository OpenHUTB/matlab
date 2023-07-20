function[ResultDescription,ResultDetails]=IdentifyActiveMMO(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyActiveMMO');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:MMOCheckDescription'));


    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);





    [refMdls,~]=find_mdlrefs(system,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

    activeSystem={};
    activeSetting={};
    hasActiveMMO=false;
    k=0;
    for i=1:numel(refMdls)
        load_system(refMdls{i});
        setting=get_param(refMdls{i},'MinMaxOverflowLogging');
        hasActiveMMO=~strcmpi(setting,'UseLocalSettings')&&~strcmpi(setting,'ForceOff');
        if hasActiveMMO
            activeSystem=[activeSystem,refMdls(i)];%#ok<*NASGU>
            activeSetting=[activeSetting,{setting}];
        end
        if~strcmpi(setting,'ForceOff')
            [hasActiveMMO,systems,settings]=detectActiveMMO(refMdls{i});%#ok<*ASGLU>
            activeSystem=[activeSystem,systems];%#ok<*NASGU>
            activeSetting=[activeSetting,settings];
        end

    end

    if~isempty(activeSystem)
        Pass=false;
    end

    if~Pass



        table=cell(length(activeSystem),2);
        for i=1:length(activeSystem)
            text=ModelAdvisor.Text(activeSystem{i});
            text.setHyperlink(['matlab:open_system(','''',activeSystem{i},'''',')']);
            table{i,1}=text;
            table{i,2}=activeSetting{i};
            mdladvObj.UserData.FixedPoint.Instrumentation.System{i}=activeSystem{i};
            mdladvObj.UserData.FixedPoint.Instrumentation.Setting{i}=activeSetting{i};
        end

        tableName='';
        h1='Path';
        h2='Current setting';
        heading={h1,h2};
        resultTable=utilDrawReportTable(table,tableName,{},heading);


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:MMOCheckResult'));

        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        result_paragraph.addItem(resultTable.emitHTML);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';


    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        utilRunFix(mdladvObj,currentCheck,Pass);
    end


    if(Pass)
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

    function[b,systems,settings]=detectActiveMMO(sysPath)

        b=false;
        systems={};
        settings={};
        sysObj=get_param(sysPath,'Object');
        children=sysObj.getHierarchicalChildren;
        if~isempty(children)
            ch=find(children,'-depth',0,'-isa','Stateflow.Chart',...
            '-or','-isa','Stateflow.LinkChart',...
            '-or','-isa','Stateflow.EMChart',...
            '-or','-isa','Stateflow.TruthTableChart',...
            '-or','-isa','Stateflow.ReactiveTestingTableChart',...
            '-or','-isa','Stateflow.StateTransitionTableChart',...
            '-or','-isa','Simulink.SubSystem');%#ok<GTARG>
        else
            ch=[];
        end
        for i=1:numel(ch)
            child=ch(i);
            if fxptds.isStateflowChartObject(child)

                child=ch(i).up;
            end
            if isequal(child,sysObj)



                continue;
            end
            val=get_param(child.getFullName,'MinMaxOverflowLogging');
            b=~strcmpi(val,'UseLocalSettings')&&~strcmpi(val,'ForceOff');
            if b
                systems=[systems,{child.getFullName}];
                settings=[settings,{val}];
            end
            [~,sys,paramVal]=detectActiveMMO(child.getFullName);
            if~isempty(sys)
                systems=[systems,sys];%#ok<*AGROW>
                settings=[settings,paramVal];
            end
        end
