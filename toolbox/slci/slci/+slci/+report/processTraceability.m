
function trace=processTraceability(datamgr,reportConfig)


    resultTableReader=datamgr.getReader('RESULTS');


    trace=struct('model',[],'code',[],'notProcessed',[],...
    'functionCall',[],'subFuncName',[],...
    'subFuncFileName',[]);


    pCodeTraceReport=slci.internal.Profiler('SLCI','CodeToModelTraceability','','');

    codeReader=datamgr.getReader('CODE');
    codeKeys=codeReader.getKeys();
    if~isempty(codeKeys)&&...
        resultTableReader.hasObject('CodeTraceabilityStatus')&&...
        ~strcmp(resultTableReader.getObject('CodeTraceabilityStatus'),'UNKNOWN')
        try
            [trace.code,trace.notProcessed]=...
            slci.report.getCodeTrace(codeKeys,datamgr,reportConfig);
        catch exception

            pCodeTraceReport.stop();
            m='Slci:report:CodeTraceDataError';
            DAStudio.error(m);
        end
    else
        trace.code=[];
        trace.notProcessed=[];
    end

    pCodeTraceReport.stop();



    pModelTraceReport=...
    slci.internal.Profiler('SLCI','ModelToCodeTraceability','','');


    if resultTableReader.hasObject('ModelTraceabilityStatus')&&...
        ~strcmp(resultTableReader.getObject('ModelTraceabilityStatus'),'UNKNOWN')
        try
            trace.model=slci.report.getModelTrace(datamgr,reportConfig);
        catch exception

            pModelTraceReport.stop();
            m='Slci:report:ModelTraceDataError';
            DAStudio.error(m);
        end
    else
        trace.model=[];
    end

    pModelTraceReport.stop();


    try
        [trace.subFuncName,trace.subFuncFileName]=...
        slci.report.getSubSystemData(datamgr);
    catch exception
        disp(exception.message)
        disp(exception.stack(1))

        DAStudio.error('Slci:report:SubSystemDataError');
    end


end
