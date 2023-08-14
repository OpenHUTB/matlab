function simDataOut=runSimulation(obj,simData,propertyProvingBlocks)






    numTestCases=length(simData);




    cleanUpActions=configureSimState();%#ok<*NASGU>

    obj.convertSldvDataToTimeSeries(simData);

    if~obj.useParallel
        cachedValidator=cv('Private','runningSLDVResultsValidator');
    else



        cachedValidator=fetchOutputs(parfeval(obj.simManager.SimulationRunner.Pool,@cv,1,'Private','runningSLDVResultsValidator'));
    end




    if nargin==3
        blocks=propertyProvingBlocks;
    else
        blocks={};
    end

    simIns=createSimulationInputObjects(obj,numTestCases,blocks,cachedValidator);

    if isempty(simIns)



        simDataOut=[];
        return;
    end








    currentBaseWSVariables=who('coveragedata*');
    currentBaseWSValues=cellfun(@(eachVar)evalin('base',eachVar),currentBaseWSVariables,'UniformOutput',false);
    evalin('base','clearvars coveragedata*');
    oc=onCleanup(@()restoreVariables(currentBaseWSVariables,currentBaseWSValues));

    if obj.useParallel
        simDataOut=obj.simManagerEngine.executeSims(@sim,simIns);
    else


        simDataOut=Simulink.SimulationOutput.empty;
        for idx=1:length(simIns)







            simIns(idx)=simIns(idx).setModelParameter('CaptureErrors','on');



            xilCleanUpActions=[];
            if obj.IsXilMode
                xilCleanUpActions=sldv.code.xil.CodeAnalyzer.registerXILSimulationPlugins(...
                obj.Model,obj.isXilAtomicSubsystem());







                if obj.SimDataTimeSeries(idx).testCaseId==1&&~isempty(simIns(idx).Variables)
                    sim(obj.Model,'StopTime','0');
                end
            end

            simDataOut(idx)=sim(simIns(idx));

            delete(xilCleanUpActions);
        end
    end
    cleanUpActions=[];
end

function simIns=createSimulationInputObjects(obj,numTestCases,blocks,cachedValidator)
    simIns=Simulink.SimulationInput.empty;
    currentSi=0;
    isTC=0;


    for i=1:numTestCases
        currentTCSimIn=Simulink.SimulationInput(obj.Model);


        if isfield(obj.SldvData,'TestCases')
            currentTCSimIn=setExternalInput(currentTCSimIn,obj.SldvData.TestCases(i).dataValues);
            isTC=1;
        else
            assert(isfield(obj.SldvData,'CounterExamples'));
            currentTCSimIn=setExternalInput(currentTCSimIn,obj.SldvData.CounterExamples(i).dataValues);
            if Sldv.utils.isActiveLogic(obj.SldvData.AnalysisInformation.Options)||...
                (strcmp(obj.SldvData.AnalysisInformation.Options.Mode,'DesignErrorDetection')&&...
                slavteng('feature','DedValidation'))
                isTC=1;
            else
                isTC=0;
            end
        end


        currentTCSimIn=obj.assignVariablesToSimulationInput(currentTCSimIn,i);


        currentTCSimIn=setModelParameter(currentTCSimIn,'StopTime',...
        sldvshareprivate('util_double2str',obj.SimDataTimeSeries(i).timeValues(end)));



        currentTCSimIn=currentTCSimIn.setPreSimFcn(@(x)preSim(x));
        currentTCSimIn=currentTCSimIn.setPostSimFcn(@(x)postSim(x,cachedValidator));

        if~isTC




            if~isempty(blocks)
                for blkIdx=1:length(blocks{i})
                    currentSi=currentSi+1;
                    currentBlkSimIn=currentTCSimIn;

                    if~isempty(blocks{i}(blkIdx).Handle)
                        BlkPath=getfullname(blocks{i}(blkIdx).Handle);
                        type=blocks{i}(blkIdx).Type;

                        if strcmp(type,'Assert')
                            currentBlkSimIn=setBlockParameter(currentBlkSimIn,BlkPath,'StopWhenAssertionFail','on');
                        else
                            currentBlkSimIn=setBlockParameter(currentBlkSimIn,BlkPath,'enableStopSim','on');
                        end
                    end

                    simIns(currentSi)=currentBlkSimIn;
                end
            end
        else
            currentSi=currentSi+1;
            simIns(currentSi)=currentTCSimIn;
        end
    end
end

function cleanUpActions=configureSimState()










    warnIDs={'backtrace','Simulink:Commands:SimulationsWithErrors','Simulink:blocks:AssertionAssert'};

    cleanUpActions=[];
    for idx=1:numel(warnIDs)
        warnState=warning('query',warnIDs{idx});
        warning('off',warnIDs{idx});



        cleanUpWarn=onCleanup(@()(warning(warnState.state,warnState.identifier)));
        cleanUpActions=[cleanUpActions,cleanUpWarn];%#ok<AGROW>
    end


    testingSFInBat=sf('Private','testing_stateflow_in_bat');

    sf('Private','testing_stateflow_in_bat',1);

    cleanUpTestingSFInBat=onCleanup(@()(sf('Private','testing_stateflow_in_bat',testingSFInBat)));
    cleanUpActions=[cleanUpActions,cleanUpTestingSFInBat];
end

function restoreVariables(variables,values)


    evalin('base','clearvars coveragedata*');

    if numel(variables)>0
        cellfun(@(idx)assignin('base',variables{idx},values{idx}),{1:length(variables)});
    end
end



function in=preSim(in)
    cv('Private','runningSLDVResultsValidator',true);
end


function out=postSim(out,cachedValidator)
    cv('Private','runningSLDVResultsValidator',cachedValidator);
end



