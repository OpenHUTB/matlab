function logDiagnostics(~,analysisPhase,msg)




    if~(slavteng('feature','LogSLDVDDUX'))

        return;
    end


    eventKey="DV_ANALYSIS_DIAGNOSTICS";
    data.analysisPhase=analysisPhase.char;
    data.diagnosticMsgID1='';
    data.diagnosticMsgID2='';
    data.diagnosticMsgID3='';
    data.diagnosticMsgID4='';
    data.diagnosticMsgID5='';




    messages=flip({msg.msgid});

    for currIdx=1:min(5,numel(messages))
        data.(['diagnosticMsgID',num2str(currIdx)])=messages{currIdx};
    end


    sldv.ddux.Logger.getInstance().logData(eventKey,data);

end


