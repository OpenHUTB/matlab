

function filterOutSignalData(startTime,stopTime,orgStartTime,signals,shiftTimeToZero)
    eng=Simulink.sdi.Instance.engine;
    for i=1:length(signals)

        signalObj=signals(i);
        values=signalObj.Values;
        wParser=Simulink.sdi.Instance.engine.WksParser;
        parsedData=wParser.parseVariables(struct('VarName','values','VarValue',values));
        parsedData=parsedData{1};

        if~isempty(parsedData.getChildren())
            continue;
        end


        if numel(parsedData.getDataValues())==1
            onlyTime=parsedData.getTimeValues();
            onlyData=parsedData.getDataValues();
            signalObj.removeTimePoints('start',onlyTime,'end',onlyTime,'splice',false);
            if shiftTimeToZero
                eng.sigRepository.addSignalTimePoint(signalObj.id,0,onlyData);
            else
                eng.sigRepository.addSignalTimePoint(signalObj.id,startTime,onlyData);
            end
            continue;
        end

        signalTimes=parsedData.getTimeValues();
        startTimesToRemove=signalTimes(signalTimes<startTime);
        endTimesToRemove=signalTimes(signalTimes>stopTime);

        if~isempty(startTimesToRemove)
            signalObj.removeTimePoints('start',startTimesToRemove(1),'end',startTimesToRemove(end),'splice',false);
        end


        signalObj.Values.Time=signalObj.Values.Time;

        if~isempty(endTimesToRemove)
            signalObj.removeTimePoints('start',endTimesToRemove(1),'end',endTimesToRemove(end),'splice',false);
        end

        if shiftTimeToZero&&~isempty(signalTimes)
            signalObj.Values.Time=signalObj.Values.Time-(signalObj.Values.Time(1)-orgStartTime);
        else


            signalObj.Values.Time=signalObj.Values.Time;
        end


        if eng.getMetaDataV2(signalObj.ID,'IsAssessment')
            if eng.getMetaDataV2(signalObj.ID,'AssessmentResult')~=int32(slTestResult.Untested)
                signalValues=signalObj.Values.Data;
                foundPass=any(signalValues==slTestResult.Pass);
                foundFail=any(signalValues==slTestResult.Fail);
                if foundFail
                    result=int32(slTestResult.Fail);
                elseif foundPass
                    result=int32(slTestResult.Pass);
                else
                    result=int32(slTestResult.Untested);
                end
                eng.setMetaDataV2(signalObj.ID,'AssessmentResult',result);
            end
        end
    end
end