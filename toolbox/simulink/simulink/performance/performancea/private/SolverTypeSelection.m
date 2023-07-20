function[ResultDescription,ResultDetails]=SolverTypeSelection(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.SolverTypeSelection');


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end




    simMode=get_param(model,'SimulationMode');
    oldSolverName=get_param(model,'SolverName');

    isFixedStepSolver=strcmp(get_param(model,'SolverType'),'Fixed-step');

    implicitSolver={'ode15s','ode23s','ode23t','ode23tb','ode14x'};
    explicitSolver={'ode45','ode23','ode113','ode1','ode2','ode3','ode4','ode5','ode8'};
    discreteSolver={'FixedStepDiscrete','VariableStepDiscrete'};
    autoSolver={'FixedStepAuto','VariableStepAuto'};


    set_param(model,'SimulationMode','Normal');


    if~any(strcmp(oldSolverName,discreteSolver))
        if isFixedStepSolver
            configSet.set_param('Solver','ode14x');
        else
            configSet.set_param('Solver','ode15s');
        end
    end

    try
        evalc([model,'([],[],[],''compile'')']);
    catch ME
        configSet.set_param('SolverName',oldSolverName);
        set_param(model,'SimulationMode',simMode);
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setCheckErrorSeverity(1);
        mdladvObj.setActionEnable(false);

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
        return;
    end

    sizeInfo=feval(model,[],[],[],'sizes');

    ncstate=sizeInfo(1);

    newSolverName=oldSolverName;

    hasPowerGui=false;
    isLinearlyImplicitModel=false;
    highStiffness=false;
    isHmaxChoked=false;
    oldSolverType='';

    if(ncstate==0)

        if any(strcmp(oldSolverName,discreteSolver))
            Pass=true;
            oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Discrete');
            newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Discrete');
            newSolverName=oldSolverName;
        else
            Pass=false;

            if any(strcmp(oldSolverName,implicitSolver))
                oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Implicit');
            elseif any(strcmp(oldSolverName,explicitSolver))
                oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Explicit');
            end
            newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Discrete');

            isFixedStepSolver=strcmp(get_param(model,'SolverType'),'Fixed-step');

            if(isFixedStepSolver)
                newSolverName='FixedStepDiscrete';
            else
                newSolverName='VariableStepDiscrete';
            end

        end
    else

        if any(strcmp(oldSolverName,discreteSolver))
            oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Discrete');
        else
            if any(strcmp(oldSolverName,implicitSolver))
                oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Implicit');
            elseif any(strcmp(oldSolverName,explicitSolver))
                oldSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Explicit');
            end
        end








        SL_CS_STATUS_POWERGUI=32;

        solverFlags=get_param(model,'SolverStatusFlags');



        isLinearlyImplicitModel=strcmp(get_param(model,'isLinearlyImplicit'),'on');
        if(isLinearlyImplicitModel)
            newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Implicit');
            Pass=any(strcmp(oldSolverName,implicitSolver));
            if~Pass
                if(isFixedStepSolver)
                    newSolverName='ode14x';
                else
                    newSolverName='ode23t';
                end
            end
        else
            hasPowerGui=bitand(solverFlags,SL_CS_STATUS_POWERGUI);
            if(hasPowerGui)
                Pass=strcmp(oldSolverName,'ode23tb');
                if(~Pass)
                    newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Implicit');
                    newSolverName='ode23tb';
                end
            else

                try
                    Jm=eval([model,'([],[],[],''slvrJacobian'')']);

                    result=slprivate('isStiffSystem',Jm,model);

                    highStiffness=result.isStiff;

                    if(highStiffness)
                        newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Implicit');
                        Pass=any(strcmp(oldSolverName,implicitSolver));
                        if~Pass
                            if(isFixedStepSolver)
                                newSolverName='ode14x';
                            else
                                newSolverName='ode15s';
                            end
                        end
                    else
                        newSolverType=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Explicit');
                        Pass=any(strcmp(oldSolverName,explicitSolver));
                        if~Pass
                            if(isFixedStepSolver)
                                newSolverName='ode3';
                            else
                                newSolverName='ode45';
                            end
                        end
                    end

                catch me

                    mdladvObj.setCheckResultStatus(false);
                    mdladvObj.setCheckErrorSeverity(1);
                    mdladvObj.setActionEnable(false);

                    [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
                    evalc([model,'([],[],[],''term'')']);

                    configSet.set_param('SolverName',oldSolverName);
                    set_param(model,'SimulationMode',simMode);

                    return;
                end
            end
        end
    end


    evalc([model,'([],[],[],''term'')']);
    pause(0.5);


    configSet.set_param('SolverName',oldSolverName);
    set_param(model,'SimulationMode',simMode);





    table=cell(1,4);
    tableName='';

    table{1,1}=utilGetStatusImgLink(Pass);
    s1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverName');
    s2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverType');
    table{1,2}=ModelAdvisor.Text(strcat(s1,'--',s2));

    link=utilCreateConfigSetHref(model,'SolverName');
    table{1,2}.setHyperlink(link);


    delim='--';
    if any(strcmp(oldSolverName,autoSolver))
        delim='';
    end

    table{1,3}=strcat(oldSolverName,delim,oldSolverType);
    table{1,4}=strcat(newSolverName,'--',newSolverType);

    h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Severity');
    h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SettingChecked');
    h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
    h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');

    heading={h1,h2,h3,h4};

    resultTable=utilDrawReportTable(table,tableName,{},heading);

    if~Pass


        if(hasPowerGui)
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionAdviceSPS',oldSolverName,newSolverName,cfsString,model));
        elseif(isLinearlyImplicitModel)
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionAdviceLinearlyImplicit',oldSolverName,newSolverName,cfsString,model));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionAdviceStiff',oldSolverName,newSolverName,cfsString,model));
        end

        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        result_paragraph.addItem(resultTable.emitHTML);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

        if(ncstate==0)
            if~isequal(oldSolverName,newSolverName)
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionAdviceDisc',oldSolverName,newSolverName));
                result_paragraph.addItem(result_text);
            end

            result_paragraph.addItem(resultTable.emitHTML);
        else

            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverTypeSelectionAdviceStiff',oldSolverName,newSolverName,cfsString,model));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendPassed'));
            result_paragraph.addItem(result_text);


            result_paragraph.addItem(resultTable.emitHTML);
        end
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        currentCheck.ResultData.FixInfo=newSolverName;


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

end


