function compare_result=utilCompareBaseLine(mdladvObj,currentCheck,newBaseLine,oldBaseLine)

    compare_result.Pass=true;

    timePass=true;
    accuracyPass=true;

    compare_result.TimeString=ModelAdvisor.Text('Simulation time is not validated. ');
    compare_result.Time=0;
    compare_result.AccuracyString=ModelAdvisor.Text('Simulation results accuracy is not validated. ');
    compare_result.Accuracy=0;

    newTime=newBaseLine.time.total;
    oldTime=oldBaseLine.time.total;

    if isempty(oldBaseLine.time.total)||isequal(newBaseLine.time,oldBaseLine.time)
        return;
    end

    sdiEngine=mdladvObj.UserData.Progress.sdiEngine;

    [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);

    if(validateTime)
        if(newTime>oldTime)
            timePass=false;
            text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeIncreased');
            compare_result.Time=-1;
        else
            timePass=true;
            text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeDecreased');
            compare_result.Time=1;
        end
        compare_result.TimeString=ModelAdvisor.Text(text);
    end


    if(validateAccuracy)


        oldRunID=mdladvObj.UserData.Progress.sdiRunIDs(1);
        newRunID=newBaseLine.time.runID;

        difference=Simulink.sdi.compareRuns(oldRunID,newRunID);

        numComparisons=difference.count;

        diffIdx=ones(1,numComparisons);

        sameAccuracy=true;

        for i=1:numComparisons

            signalResult=difference.getResultByIndex(i);


            if signalResult.match
                diffIdx(i)=0;
            else
                diffIdx(i)=1;
                sameAccuracy=false;
            end
        end

        if(~sameAccuracy)
            accuracyPass=false;
            text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AccuracyBeyond');
            compare_result.Accuracy=-1;
        else
            accuracyPass=true;
            text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:AccuracyWithin');
            compare_result.Accuracy=1;
        end
        compare_result.AccuracyString=ModelAdvisor.Text(text);
    end

    compare_result.Pass=timePass&accuracyPass;

    sp=ModelAdvisor.Text('  ');
    compare_result.TimeString=[compare_result.TimeString,sp,ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationTime',num2str(newTime)))];

    text=utilGenerateSdiHTML(newBaseLine,oldBaseLine);

    compare_result.AccuracyString=[compare_result.AccuracyString,sp,text];

