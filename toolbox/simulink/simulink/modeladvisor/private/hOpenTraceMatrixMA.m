function hOpenTraceMatrixMA(modelFile)

    option.promptToUsers=false;
    option.queryOtherDataInMemory=false;
    try
        modelFile=get_param(modelFile,'filename');
        slreq.report.rtmx.utils.generateRTMX({modelFile},option);
    catch
        disp('req not available');
    end