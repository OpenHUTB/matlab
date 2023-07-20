



function sigTimeTable=exportSignalToTimeTable(this,signalID)



    sigTimeTable=this.sigRepository.safeTransaction(...
    @helperExportSignalToTimeTable,this,signalID);
end

function sigTimeTable=helperExportSignalToTimeTable(eng,signalID)

    if isempty(signalID)||~eng.isValidSignalID(signalID)
        sigTimeTable=timetable.empty();
        return;
    end

    Simulink.sdi.internal.flushStreamingBackend();
    if eng.sigRepository.getSignalIsActivelyStreaming(signalID)
        error(message('SDI:sdi:ExportWhileStreaming'));
    end

    sigData=eng.getSignalDataValues(signalID,true,false);

    if isempty(sigData)
        sigTimeTable=timetable.empty;
        return;
    else
        dataVals=reshape(sigData.Data,length(sigData.Data),1);
        timeVals=reshape(sigData.Time,length(sigData.Time),1);
    end


    sigProps.Name=eng.sigRepository.getSignalLabel(signalID);
    sigProps.Interp=eng.sigRepository.getSignalInterpMethod(signalID);


    sigTimeTable=timetable(...
    seconds(timeVals),dataVals,'VariableNames',{'Data'});

    if isequal(sigProps.Interp,'linear')
        sigTimeTable.Properties.VariableContinuity={'continuous'};
    else
        sigTimeTable.Properties.VariableContinuity={'step'};
    end

end


