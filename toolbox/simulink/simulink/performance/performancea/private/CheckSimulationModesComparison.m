function[ResultDescription,ResultDetails]=CheckSimulationModesComparison(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationModesComparison');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimulationModesComparisonTitle'));


    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end




    oldStopTime=get_param(model,'StopTime');
    oldStartTime=get_param(model,'StartTime');


    [~,stopTimeVal]=GetNumericValuesOfStartAndStopTimes(model,oldStartTime,oldStopTime);
    if(stopTimeVal==inf)
        msgId='perfAdvId:InfStopTime';
        msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InfiniteStopTime');
        Exception=MException(msgId,msg);
        throwAsCaller(Exception);
    end


    simMode=get_param(model,'SimulationMode');
    simCompilerOptimization=get_param(model,'SimCompilerOptimization');
    isNormal=strcmpi(simMode,'normal');
    isAccelerator=strcmpi(simMode,'accelerator');
    isRapidAccelerator=strcmpi(simMode,'rapid-accelerator');



    if~(isNormal||isAccelerator||isRapidAccelerator)
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NotSimulationMode'));
        result_paragraph.addItem(text);
    else


        if isNormal
            oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode');
        elseif(isAccelerator)
            oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode');
        else
            oldMode=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode');
        end

        try

            cleanFolder();


            if mdladvObj.UserCancel
                msgId='perfAdvId:UserCancel';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end


            if mdladvObj.GlobalTimeOut
                msgId='perfAdvId:GlobalTimeOut';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end



            set_param(model,'SimulationMode','normal');

            NormalPerfDataSet.simulationmode='normal';
            NormalPerfDataSet.simulationmode_fordisplay=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode');
            NormalPerfDataSet.simcompileroptimization=simCompilerOptimization;
            [NormalPerfDataSet.totalTime,...
            NormalPerfDataSet.Tu,...
            NormalPerfDataSet.Tuc,...
            NormalPerfDataSet.Ts,...
            NormalPerfDataSet.Tg,...
            NormalPerfDataSet.Tmrb,...
            NormalPerfDataSet.Te,...
            NormalPerfDataSet.Tt]=...
            utilGetTimingInfo(model,false);

            cleanFolder();




            if mdladvObj.UserCancel
                msgId='perfAdvId:UserCancel';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end


            if mdladvObj.GlobalTimeOut
                msgId='perfAdvId:GlobalTimeOut';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end

            set_param(model,'SimulationMode','accelerator');
            AccelPerfDataSet.simulationmode='accelerator';
            AccelPerfDataSet.simulationmode_fordisplay=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode');
            AccelPerfDataSet.simcompileroptimization=simCompilerOptimization;
            [AccelPerfDataSet.totalTime,...
            AccelPerfDataSet.Tu,...
            AccelPerfDataSet.Tuc,...
            AccelPerfDataSet.Ts,...
            AccelPerfDataSet.Tg,...
            AccelPerfDataSet.Tmrb,...
            AccelPerfDataSet.Te,...
            AccelPerfDataSet.Tt]=...
            utilGetTimingInfo(model,false);
        catch me

            cleanFolder();
            configSet.set_param('StopTime',oldStopTime);

            set_param(model,'SimulationMode',simMode);

            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);
            mdladvObj.setActionEnable(false);

            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
            return;
        end




        try

            cleanFolder();


            if mdladvObj.UserCancel
                msgId='perfAdvId:UserCancel';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end


            if mdladvObj.GlobalTimeOut
                msgId='perfAdvId:GlobalTimeOut';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end


            set_param(model,'SimulationMode','rapid-accelerator');
            RAccelPerfDataSet.simulationmode='rapid-accelerator';
            RAccelPerfDataSet.simulationmode_fordisplay=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode');
            RAccelPerfDataSet.simcompileroptimization=simCompilerOptimization;
            [RAccelPerfDataSet.totalTime,...
            RAccelPerfDataSet.Tu,...
            RAccelPerfDataSet.Tuc,...
            RAccelPerfDataSet.Ts,...
            RAccelPerfDataSet.Tg,...
            RAccelPerfDataSet.Tmrb,...
            RAccelPerfDataSet.Te,...
            RAccelPerfDataSet.Tt]=...
            utilGetTimingInfo(model,false);
            RAccelPerfDataSet.error=false;

            cleanFolder();

        catch me


            configSet.set_param('StopTime',oldStopTime);



            if strcmp(me.identifier,'perfAdvId:GlobalTimeOut')||strcmp(me.identifier,'perfAdvId:UserCancel')
                cleanFolder();

                set_param(model,'SimulationMode',simMode);

                mdladvObj.setCheckResultStatus(false);
                mdladvObj.setCheckErrorSeverity(1);
                mdladvObj.setActionEnable(false);

                [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
                return;
            else

                RAccelPerfDataSet.totalTime=Inf;
                RAccelPerfDataSet.Tu=Inf;
                RAccelPerfDataSet.Tuc=Inf;
                RAccelPerfDataSet.Ts=Inf;
                RAccelPerfDataSet.Tg=Inf;
                RAccelPerfDataSet.Tmrb=Inf;
                RAccelPerfDataSet.Te=Inf;
                RAccelPerfDataSet.Tt=Inf;



                RAccelPerfDataSet.error=true;
                RAccelErrorMessage=me.message;
                RAccelErrorCause=me.cause;
            end

        end

        cleanFolder();


        set_param(model,'SimulationMode',simMode);


        workDir=mdladvObj.getWorkDir;
        [fileName,bestDataSet,secondBestDataSet,...
        NormalPerfDataSet,AccelPerfDataSet,...
        RAccelPerfDataSet,RAccelUOffPerfDataSet]=...
        createFullPerfData(NormalPerfDataSet,...
        AccelPerfDataSet,...
        RAccelPerfDataSet,...
        simMode,...
        workDir);




        if(RAccelPerfDataSet.error)
            tags=cell(2,1);
            slopes=[NormalPerfDataSet.slope,AccelPerfDataSet.slope];
            offsets=[NormalPerfDataSet.offset,AccelPerfDataSet.offset];
        else
            tags=cell(4,1);
            slopes=[NormalPerfDataSet.slope,AccelPerfDataSet.slope,RAccelPerfDataSet.slope,RAccelUOffPerfDataSet.slope];
            offsets=[NormalPerfDataSet.offset,AccelPerfDataSet.offset,RAccelPerfDataSet.offset,RAccelUOffPerfDataSet.offset];
        end
        [setIds,simRange]=utilCompareAllSets(slopes,offsets);
        Warning=false;

        modes={'normal','accelerator','rapid-accelerator','rapid-accelerator'};
        optimalModes=cell(numel(setIds),1);
        for i=1:numel(optimalModes)
            optimalModes{i}=modes{setIds(i)};
        end
        match_found=find(ismember(optimalModes,simMode),1);
        if(~strcmpi(bestDataSet.simulationmode,simMode)||numel(setIds)>1)
            Pass=false;
            if(strcmpi(bestDataSet.simulationmode,simMode)||~isempty(match_found))
                Warning=true;
            end
        end








        newMode=bestDataSet.simulationmode_fordisplay;


        mdladvObj.setCheckResultStatus(Pass);

        WriteCheckResults(mdladvObj,bestDataSet,...
        NormalPerfDataSet,AccelPerfDataSet,...
        RAccelPerfDataSet,RAccelUOffPerfDataSet);

        if~Pass
            if(Warning==true||isequal(oldMode,newMode))
                text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReviewComparisonBetweenModes',oldMode));
                result_paragraph.addItem(text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            else
                text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TryDifferentMode',oldMode,newMode));
                result_paragraph.addItem(text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            end


            addRapidAcceleratorSpecificAdvice(result_paragraph,bestDataSet);

            actionMode=utilCheckActionMode(mdladvObj,currentCheck);
            if strfind(actionMode,'Manually')
                action=currentCheck.getAction;
                fixButtonName=action.Name;
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModeAdviceAppendManually',fixButtonName));
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
            result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModeAdviceAppendPassed',oldMode)));
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

            addRapidAcceleratorSpecificAdvice(result_paragraph,bestDataSet);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        end


        imgstr=strcat(' <img src =','" ','file:///',fileName,'"','/>');
        result_text=ModelAdvisor.Text(imgstr);
        result_paragraph.addItem([ModelAdvisor.LineBreak,result_text]);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);



        if(Pass)


            bestDataSet=secondBestDataSet;
            newMode=secondBestDataSet.simulationmode_fordisplay;
        end


        startTime=configSet.get_param('StartTime');
        stopTime=configSet.get_param('StopTime');
        [startTime,stopTime]=GetNumericValuesOfStartAndStopTimes(model,startTime,stopTime);

        simTime=stopTime-startTime;


        table1=cell(1,3);

        table1{1,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:RequestedSimulationTime'));
        table1{1,2}=num2str(simTime);


        table1{1,3}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationSecondsUnits'));


        tableName1='';
        h1_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MeasurementName');
        h2_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Value');
        h3_1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Units');
        heading1={h1_1,h2_1,h3_1};
        resultTable1=utilDrawReportTable(table1,tableName1,{},heading1);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(resultTable1.emitHTML);


        tags{1}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode');
        tags{2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode');
        if(~RAccelPerfDataSet.error)
            tags{3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode');
            tags{4}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorModeUpToDateCheckOff');
        end

        optModeTable=cell(numel(setIds),3);
        for i=1:numel(setIds)
            optModeTable{i,1}=tags{setIds(i)};
            optModeTable{i,2}=sprintf('%.i',simRange(i,1));
            optModeTable{i,3}=sprintf('%.i',simRange(i,2));
        end
        optModeTableHeading=cell(1,3);
        optModeTableHeading{1}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedSimulationMode');
        optModeTableHeading{2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NumberOfSimulationsLowerRange');
        optModeTableHeading{3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NumberOfSimulationsUpperRange');
        optModeTableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedSimulationModeTitle');
        optModeTableResult=utilDrawReportTable(optModeTable,optModeTableName,{},optModeTableHeading);

        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(optModeTableResult.emitHTML);

        if(RAccelPerfDataSet.error)
            table2=cell(4,4);
        else
            table2=cell(4,6);
        end


        table2{1,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeElapsedDuringBuild'));
        table2{2,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeElapsedDuringSimulation'));
        table2{3,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRate'));
        table2{4,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateWithoutOverheads'));


        table2{1,2}=sprintf('%.3f',NormalPerfDataSet.offset);
        table2{2,2}=sprintf('%.3f',NormalPerfDataSet.slope);
        table2{3,2}=sprintf('%.3f',simTime/NormalPerfDataSet.slope);
        table2{4,2}=sprintf('%.3f',simTime/NormalPerfDataSet.Te);


        table2{1,3}=sprintf('%.3f',AccelPerfDataSet.offset);
        table2{2,3}=sprintf('%.3f',AccelPerfDataSet.slope);
        table2{3,3}=sprintf('%.3f',simTime/AccelPerfDataSet.slope);
        table2{4,3}=sprintf('%.3f',simTime/AccelPerfDataSet.Te);

        if(RAccelPerfDataSet.error)

            table2{1,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
            table2{2,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
            table2{3,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));
            table2{4,4}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));
        else

            table2{1,4}=sprintf('%.3f',RAccelPerfDataSet.offset);
            table2{2,4}=sprintf('%.3f',RAccelPerfDataSet.slope);
            table2{3,4}=sprintf('%.3f',simTime/RAccelPerfDataSet.slope);
            table2{4,4}=sprintf('%.3f',simTime/RAccelPerfDataSet.Te);


            table2{1,5}=sprintf('%.3f (*)',RAccelUOffPerfDataSet.offset);
            table2{2,5}=sprintf('%.3f',RAccelUOffPerfDataSet.slope);
            table2{3,5}=sprintf('%.3f',simTime/RAccelUOffPerfDataSet.slope);
            table2{4,5}=sprintf('%.3f',simTime/RAccelUOffPerfDataSet.Te);


            table2{1,6}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
            table2{2,6}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WallClockSecondsUnits'));
            table2{3,6}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));
            table2{4,6}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRateUnits'));
        end




        tableName2='';
        h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MeasurementName');
        h2=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode'));
        h3=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode'));
        if(RAccelPerfDataSet.error)
            h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Units');
            heading2={h1,h2,h3,h4};
        else
            h4=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode'));
            h5=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorModeUpToDateCheckOff'));
            h6=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Units');
            heading2={h1,h2,h3,h4,h5,h6};
        end
        resultTable=utilDrawReportTable(table2,tableName2,{},heading2);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(resultTable.emitHTML);



        if(~RAccelPerfDataSet.error)
            result_paragraph.addItem(ModelAdvisor.LineBreak);
            rapidAccelUpToDateCheckOffFootnoteText=...
            ModelAdvisor.Text(DAStudio.message(...
            'SimulinkPerformanceAdvisor:advisor:RapidAcceleratorModeUpToDateCheckOffBuildTimeFootnote'));
            result_paragraph.addItem(rapidAccelUpToDateCheckOffFootnoteText);
        end


        if(RAccelPerfDataSet.error)
            result_paragraph.addItem(ModelAdvisor.LineBreak);
            result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorSimulationIssue')));
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            result_paragraph.addItem(RAccelErrorMessage);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


            for i=1:length(RAccelErrorCause)
                result_paragraph.addItem(RAccelErrorCause{i}.message);
                result_paragraph.addItem(ModelAdvisor.LineBreak);
            end
        end

        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message(...
        'SimulinkPerformanceAdvisor:advisor:CompareModesAlgorithmFootnote')));

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


end


function WriteCheckResults(mdladvObj,bestDataSet,...
    NormalPerfDataSet,AccelPerfDataSet,RAccelPerfDataSet,RAccelUOffPerfDataSet)






    mdladvObj.UserData.SimTargetTestsData.SimulationMode.ResultData.bestDataSet=bestDataSet;




    mdladvObj.UserData.SimTargetTestsData.ResultData.NormalPerfDataSet=NormalPerfDataSet;
    mdladvObj.UserData.SimTargetTestsData.ResultData.AccelPerfDataSet=AccelPerfDataSet;
    mdladvObj.UserData.SimTargetTestsData.ResultData.RAccelPerfDataSet=RAccelPerfDataSet;
    mdladvObj.UserData.SimTargetTestsData.ResultData.RAccelUOffPerfDataSet=RAccelUOffPerfDataSet;
end


function addRapidAcceleratorSpecificAdvice(result_paragraph,bestDataSet)
    if(strcmpi(bestDataSet.simulationmode,'rapid-accelerator'))
        if(strcmpi(bestDataSet.uptodatecheck,'off'))
            text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAccelUpToDateCheckOffAdvice'));
            result_paragraph.addItem(text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        end
    end
end


function[filePath,bestDataSet,secondBestDataSet,...
    normal,accel,raccel,racceluoff]=...
    createFullPerfData(normal,accel,raccel,simMode,workDir)



    normal.slope=normal.Tu+normal.Tuc+normal.Ts+normal.Te+normal.Tt;
    normal.offset=normal.Tg+normal.Tmrb;
    normal.uptodatecheck='On';

    accel.slope=accel.Tu+accel.Tuc+accel.Ts+accel.Te+accel.Tt;
    accel.offset=accel.Tg+accel.Tmrb;
    accel.uptodatecheck='On';

    raccel.slope=raccel.Tu+raccel.Tuc+raccel.Ts+raccel.Te+raccel.Tt;
    raccel.offset=raccel.Tg+raccel.Tmrb;
    raccel.uptodatecheck='On';

    racceluoff=raccel;
    racceluoff.slope=racceluoff.Ts+racceluoff.Te+racceluoff.Tt;
    racceluoff.uptodatecheck='Off';

    bestDataSet=accel;
    secondBestDataSet=normal;

    if utilCompareSets(bestDataSet,secondBestDataSet,simMode)
        bestDataSet=normal;
        secondBestDataSet=accel;
    end

    if(~raccel.error)
        [bestDataSet,secondBestDataSet]=...
        compareResults(bestDataSet,secondBestDataSet,raccel,simMode);
        [bestDataSet,secondBestDataSet]=...
        compareResults(bestDataSet,secondBestDataSet,racceluoff,simMode);
    end


    runs=logspace(0,3,31);
    f=figure('visible','off');
    set(f,'color',[1,1,1]);


    normal.time=normal.offset+normal.slope*runs;
    accel.time=accel.offset+accel.slope*runs;
    raccel.time=raccel.offset+raccel.slope*runs;
    racceluoff.time=racceluoff.offset+racceluoff.slope*runs;

    if(raccel.error)
        loglog(runs,normal.time,'g-',...
        runs,accel.time,'r--');
    else
        loglog(runs,normal.time,'g-',...
        runs,accel.time,'r--',...
        runs,raccel.time,'b-.',...
        runs,racceluoff.time,'c-o');
    end
    grid on
    title(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModeFigTitle'));
    xlabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModeFigXlabel'));
    ylabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationModeFigYlabel'));
    if(raccel.error)
        legend(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode'),...
        DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode'),...
        'Location','SouthOutside');
    else
        legend(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NormalMode'),...
        DAStudio.message('SimulinkPerformanceAdvisor:advisor:AcceleratorMode'),...
        DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorMode'),...
        DAStudio.message('SimulinkPerformanceAdvisor:advisor:RapidAcceleratorModeUpToDateCheckOff'),...
        'Location','SouthOutside');
    end

    fileName=fullfile(workDir,'simulationmodes.png');

    scrpos=get(f,'Position');
    newpos=scrpos/75;

    set(f,'PaperUnits','inches','PaperPosition',newpos);
    print(f,'-dpng',fileName,'-r100');

    filePath=strcat(fileName);
    close(f);

end



function[bestDataSet,secondBestDataSet]=...
    compareResults(bestset,secondbestset,newset,currentset)
    if utilCompareSets(bestset,newset,currentset)
        secondBestDataSet=bestset;
        bestDataSet=newset;
    else
        bestDataSet=bestset;
        if(utilCompareSets(secondbestset,newset,currentset)||...
            strcmpi(bestset.simulationmode,secondbestset.simulationmode))
            secondBestDataSet=newset;
        else
            secondBestDataSet=secondbestset;
        end
    end
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
                    delete(w.mex{fileindex});
                end
            end
        end
    catch me %#ok<*NASGU>

    end
end







function[startTime,stopTime]=GetNumericValuesOfStartAndStopTimes(model,...
    startTimeString,...
    stopTimeString)
    startTime=GetNumericValueOfTimeString(model,startTimeString);
    stopTime=GetNumericValueOfTimeString(model,stopTimeString);
end

function time=GetNumericValueOfTimeString(model,timeString)
    time=0;
    if(~isnan(str2double(timeString)))

        time=str2double(timeString);
    else


        try
            mdlWS=get_param(model,'ModelWorkSpace');
            time=evalin(mdlWS,timeString);
        catch
            try
                time=evalin('base',timeString);
            catch



                errorMsg=DAStudio.message(...
                'SimulinkPerformanceAdvisor:advisor:InvalidStartAndOrStopTime');
                time=NaN;
            end
        end
    end
end



