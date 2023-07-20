function[ResultDescription,ResultDetails]=CheckSimulationCompilerOptimization(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationCompilerOptimization');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationCompilerOptimizationTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end




    oldStopTime=get_param(model,'StopTime');

    simMode=get_param(model,'SimulationMode');
    simCompilerOptimization=get_param(model,'SimCompilerOptimization');
    isNormal=strcmpi(simMode,'normal');
    isAccelerator=strcmpi(simMode,'accelerator');
    isRapidAccelerator=strcmpi(simMode,'rapid-accelerator');
    isSimCompilerOptimization=strcmpi(simCompilerOptimization,'on');
    hasDataflow=~isempty(Simulink.findBlocksOfType(bdroot,'SubSystem','SetExecutionDomain','on','ExecutionDomainType','Dataflow'));

    isLCC=false;
    comp=rtwprivate('getMexCompilerInfo');
    if(isempty(comp)||(sfpref('UseLCC64ForSimulink')&&...
        strcmpi(computer('arch'),'win64')))
        isLCC=true;
    else
        compilerName=lower(comp(1).compStr);
        if(~isempty(strfind(compilerName,'lcc')))
            isLCC=true;
        end
    end

    if~(isAccelerator||isRapidAccelerator||hasDataflow)
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NotCodegenSimulationMode'));
        result_paragraph.addItem(text);
    elseif(isLCC)
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NotOptimizingCompiler'));
        result_paragraph.addItem(text);
    else

        if isSimCompilerOptimization
            oldOptim=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOn');
            newOptim=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOff');
        else
            oldOptim=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOff');
            newOptim=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOn');
        end

        try
            stopTime=utilGetBaselineStopTime(mdladvObj,model);
            configSet.set_param('StopTime',num2str(stopTime));

            cleanFolder();
            configSet.set_param('SimCompilerOptimization','off');
            [OptimOffPerfData.totalTime,...
            OptimOffPerfData.Tu,...
            OptimOffPerfData.Tuc,...
            OptimOffPerfData.Ts,...
            OptimOffPerfData.Tg,...
            OptimOffPerfData.Tmrb,...
            OptimOffPerfData.Te,...
            OptimOffPerfData.Tt]=...
            utilGetTimingInfo(model,false);
            OptimOffPerfData.simulationmode=get_param(model,'SimulationMode');
            OptimOffPerfData.simcompileroptimization=configSet.get_param('SimCompilerOptimization');
            OptimOffPerfData.simcompileroptimization_fordisplay=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOff');
            cleanFolder();
            configSet.set_param('SimCompilerOptimization','on');
            [OptimOnPerfData.totalTime,...
            OptimOnPerfData.Tu,...
            OptimOnPerfData.Tuc,...
            OptimOnPerfData.Ts,...
            OptimOnPerfData.Tg,...
            OptimOnPerfData.Tmrb,...
            OptimOnPerfData.Te,...
            OptimOnPerfData.Tt]=...
            utilGetTimingInfo(model,false);
            OptimOnPerfData.simulationmode=get_param(model,'SimulationMode');
            OptimOnPerfData.simcompileroptimization=configSet.get_param('SimCompilerOptimization');
            OptimOnPerfData.simcompileroptimization_fordisplay=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOn');
            cleanFolder();

        catch me

            cleanFolder();


            configSet.set_param('StopTime',oldStopTime);


            configSet.set_param('SimCompilerOptimization',simCompilerOptimization);


            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);
            mdladvObj.setActionEnable(false);

            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
            return;
        end

        configSet.set_param('SimCompilerOptimization',simCompilerOptimization);


        workDir=mdladvObj.getWorkDir;
        [fileName,bestDataSet,crossN,OptimOnPerfData,OptimOffPerfData]=...
        createFullPerfData(OptimOnPerfData,...
        OptimOffPerfData,...
        workDir);

        if(~strcmpi(bestDataSet.simcompileroptimization,...
            simCompilerOptimization)||...
            crossN>1)
            Pass=false;
        end


        mdladvObj.setCheckResultStatus(Pass);

        WriteCheckResults(mdladvObj,bestDataSet);

        if~Pass
            if(crossN>1)
                text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReviewComparisonBetweenSimCompilerOptimization',oldOptim));
                result_paragraph.addItem(text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            else
                text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TryDifferentSimCompilerOptimization',oldOptim,newOptim));
                result_paragraph.addItem(text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
                text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReviewComparisonBetweenSimCompilerOptimization',oldOptim));
                result_paragraph.addItem(text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            end

            actionMode=utilCheckActionMode(mdladvObj,currentCheck);
            if strfind(actionMode,'Manually')
                action=currentCheck.getAction;
                fixButtonName=action.Name;
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationAdviceAppendManually',system,newOptim,fixButtonName));
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            else
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendAuto'));
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            end

        else

            result_paragraph.addItem(Passed);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationAdviceAppendPassed',oldOptim,newOptim)));
        end


        imgstr=strcat(' <img src =','" ','file:///',fileName,'"','/>');
        result_text=ModelAdvisor.Text(imgstr);
        result_paragraph.addItem([ModelAdvisor.LineBreak,result_text]);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);




        simTime=str2double(configSet.get_param('StopTime'))-...
        str2double(configSet.get_param('StartTime'));

        table1=cell(2,3);


        table1{1,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationBreakevenPoint',oldOptim,newOptim));
        table1{2,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationTime2'));


        if(crossN>1)

            table1{1,2}=num2str(crossN);
        else


            table1{1,2}=num2str(0);
        end
        table1{2,2}=num2str(simTime);


        table1{1,3}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NumberOfSimulationsUnits'));
        table1{2,3}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationSecondsUnits'));


        tableName1='';
        h1_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MeasurementName');
        h2_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Value');
        h3_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Units');
        heading1={h1_1,h2_1,h3_1};
        resultTable1=utilDrawReportTable(table1,tableName1,{},heading1);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(resultTable1.emitHTML);

        table2=cell(4,4);


        table2{1,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeElapsedDuringBuild'));
        table2{2,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeElapsedDuringSimulation'));
        table2{3,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRate'));
        table2{4,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateWithoutOverheads'));


        table2{1,2}=sprintf('%.3f',OptimOffPerfData.offset);
        table2{2,2}=sprintf('%.3f',OptimOffPerfData.slope);
        table2{3,2}=sprintf('%.3f',simTime/OptimOffPerfData.slope);
        table2{4,2}=sprintf('%.3f',simTime/OptimOffPerfData.Te);


        table2{1,3}=sprintf('%.3f',OptimOnPerfData.offset);
        table2{2,3}=sprintf('%.3f',OptimOnPerfData.slope);
        table2{3,3}=sprintf('%.3f',simTime/OptimOnPerfData.slope);
        table2{4,3}=sprintf('%.3f',simTime/OptimOnPerfData.Te);


        table2{1,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
        table2{2,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
        table2{3,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));
        table2{4,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));


        tableName2='';
        h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MeasurementName');
        h2=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOff'));
        h3=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOn'));
        h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Units');
        heading2={h1,h2,h3,h4};
        resultTable=utilDrawReportTable(table2,tableName2,{},heading2);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(resultTable.emitHTML);
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



    configSet.set_param('StopTime',oldStopTime);

end


function WriteCheckResults(mdladvObj,bestDataSet)






    mdladvObj.UserData.SimTargetTestsData.SimCompilerOptimization.ResultData.bestDataSet=bestDataSet;
end


function[filePath,bestDataSet,crossN,optimon,optimoff]=...
    createFullPerfData(optimon,optimoff,workDir)


    optimon.slope=optimon.Tu+optimon.Tuc+optimon.Ts+optimon.Te+optimon.Tt;
    optimon.offset=optimon.Tg+optimon.Tmrb;
    optimoff.slope=optimoff.Tu+optimon.Tuc+optimoff.Ts+optimoff.Te+optimoff.Tt;
    optimoff.offset=optimoff.Tg+optimon.Tmrb;
    optimon.n=round((optimoff.offset-optimon.offset)/(optimon.slope-optimoff.slope))+1;
    optimon.crossN=optimon.n;
    optimoff.n=0;
    optimoff.crossN=0;

    if(optimon.n<1)
        optimon.n=10;
        optimon.crossN=-1;
    end

    if(optimon.n==1||(optimon.n>1&&optimon.slope<optimoff.slope))
        bestDataSet=optimon;
    else
        bestDataSet=optimoff;
    end

    crossN=optimon.crossN;











    f=figure('visible','off');
    set(f,'color',[1,1,1]);

    runs=logspace(0,3);
    optimon.time=optimon.offset+optimon.slope*runs;
    optimoff.time=optimoff.offset+optimoff.slope*runs;

    loglog(runs,optimoff.time,'g-',...
    runs,optimon.time,'r--');
    grid on




    title(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationFigTitle'));
    xlabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationFigXlabel'));
    ylabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationFigYlabel'));
    legend(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOff'),...
    DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimCompilerOptimizationOn'),...
    'Location','SouthOutside');






    fileName=fullfile(workDir,'simulationcompileroptimization.png');

    scrpos=get(f,'Position');
    newpos=scrpos/75;

    set(f,'PaperUnits','inches','PaperPosition',newpos);
    print(f,'-dpng',fileName,'-r100');

    filePath=strcat(fileName);
    close(f);

end











function cleanFolder()
    try
        if(exist(['slprj',filesep,'sim'],'dir')~=0)
            rmdir(['slprj',filesep,'sim'],'s');
        end
        if(exist(['slprj',filesep,'accel'],'dir')~=0)
            rmdir(['slprj',filesep,'accel'],'s');
        end
        if(exist(['slprj',filesep,'raccel'],'dir')~=0)
            rmdir(['slprj',filesep,'raccel'],'s');
        end
        if(exist(['slprj',filesep,'_sfprj'],'dir')~=0)
            rmdir(['slprj',filesep,'_sfprj'],'s');
        end
        clear mex;
        mexFilePats={['.*_acc\.',mexext],...
        ['.*_msf\.',mexext],...
        ['.*_sfun\.',mexext]};
        w=what;
        for fileindex=1:length(w.mex)
            for patindex=1:length(mexFilePats)
                isMexFile=regexp(w.mex{fileindex},mexFilePats{patindex},'once');
                if(~isempty(isMexFile))
                    if mislocked(w.mex{fileindex})
                        munlock(w.mex{fileindex});
                    end
                    delete(w.mex{fileindex});
                end
            end
        end
    catch me %#ok<*NASGU>

    end
end



