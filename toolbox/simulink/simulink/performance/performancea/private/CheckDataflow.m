function[ResultDescription,ResultDetails]=CheckDataflow(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDataflow');


    Pass=true;

    mdladvObj.UserData.Dataflow={};


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;


    hasDataflow=~isempty(Simulink.findBlocksOfType(model,'SubSystem','SetExecutionDomain','on','ExecutionDomainType','Dataflow'));


    if~hasDataflow
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowNoDataflow'));
        result_paragraph.addItem(text);
    else



        simMode=get_param(model,'SimulationMode');
        isRaccel=strcmpi(simMode,'rapid-accelerator');



        try
            if isRaccel
                Simulink.BlockDiagram.buildRapidAcceleratorTarget(model);
            else
                set_param(model,'SimulationCommand','update');
            end
        catch ME
            mdladvObj.setCheckErrorSeverity(1);
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return;
        end

        ui=get_param(model,'DataflowUI');



        if isempty(ui.MappingData)
            Pass=true;
            result_paragraph.addItem(Passed);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowNoDataflow'));
            result_paragraph.addItem(text);
        else


            if ui.NeedsProfiling


                oldStopTime=get_param(model,'StopTime');
                try
                    stopTime=utilGetBaselineStopTime(mdladvObj,model);
                    configSet.set_param('StopTime',num2str(stopTime));

                    utilGetTimingInfo(model,false);

                    if isRaccel
                        Simulink.BlockDiagram.buildRapidAcceleratorTarget(model);
                    else
                        eval([model,'([],[],[], ''compile'')']);
                        eval([model,'([],[],[], ''term'')']);
                    end

                    configSet.set_param('StopTime',oldStopTime);
                catch ME

                    configSet.set_param('StopTime',oldStopTime);
                    mdladvObj.setCheckErrorSeverity(1);
                    [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
                    return;
                end
            end

            allMappingData=ui.MappingData;


            assert(isPartitioned(allMappingData),'Not partitioned');




            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTitle'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowAllDataflowInfo'));
            result_paragraph.addItem(result_text);
            resultTable=utilDataflowResultsTable(mdladvObj,allMappingData,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoTableTitle'));
            result_paragraph.addItem(resultTable.emitHTML);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

            failedMappingData=getFailedMappingData(allMappingData);
            Pass=isempty(failedMappingData);
            actionEnable=false;

            if~Pass
                mdladvObj.UserData.Dataflow=getFixData(failedMappingData);
                actionEnable=~isempty(mdladvObj.UserData.Dataflow.OptimalLatency);
                mdladvObj.setActionEnable(actionEnable);

                result_paragraph.addItem(Warned);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
                result_text=utilAddAppendInformation(mdladvObj,currentCheck);
                if actionEnable
                    result_paragraph.addItem(result_text);
                end
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowFailedDataflowInfo'));
                result_paragraph.addItem(result_text);
                resultTable=utilDataflowResultsTable(mdladvObj,failedMappingData,DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowLimitTableTitle'));
                result_paragraph.addItem(resultTable.emitHTML);
            else

                result_paragraph.addItem(Passed);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDataflowPassed'));
                result_paragraph.addItem(result_text);
            end
        end
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';


    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        utilRunFix(mdladvObj,currentCheck,Pass);

        mdladvObj.setActionEnable(actionEnable);
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


function fixData=getFixData(failedMappingData)
    fixData.OptimalLatency={};
    for i=1:numel(failedMappingData)
        if(failedMappingData(i).OptimalLatency>failedMappingData(i).SpecifiedLatency)
            Opt.Subsys=getfullname(failedMappingData(i).TopMostDataflowSubsystem);
            Opt.OptLat=failedMappingData(i).OptimalLatency;
            fixData.OptimalLatency{end+1}=Opt;
        end
    end
end

function failedMappingData=getFailedMappingData(allMappingData)
    failedIndx=zeros(1,numel(allMappingData));
    for i=1:numel(allMappingData)





        failedIndx(i)=(...
        bitget(allMappingData(i).Attributes,10)||...
        (bitget(allMappingData(i).Attributes,8)&&~(allMappingData(i).NumberOfBlocks==0))||...
        (allMappingData(i).OptimalLatency>allMappingData(i).SpecifiedLatency)||...
        ((allMappingData(i).getCostData.TallPoleData.TallPoleRatio>0)&&...
        ~isempty(allMappingData(i).getCostData.TallPoleData.TallPoleBlock)));
    end
    failedMappingData=allMappingData(logical(failedIndx));
end

function partitioned=isPartitioned(allMappingData)
    partitioned=~isempty(allMappingData);
    for i=1:numel(allMappingData)
        if~bitget(allMappingData(i).Attributes,11)
            partitioned=false;
            return;
        end
    end
end


