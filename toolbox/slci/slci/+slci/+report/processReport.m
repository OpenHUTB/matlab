

function[dm,reportTable]=processReport(slciConfig,...
    reportConfig)


    reportTable=struct('Status','UNKNOWN',...
    'verificationStatus','UNKNOWN',...
    'traceabilityStatus','UNKNOWN',...
    'utilsStatus','UNKNOWN',...
    'modelDesc',[],...
    'codeSourceDesc',[],...
    'metaData',[],...
    'funcDescTable',[],...
    'trace',[],...
    'statusData',[],...
    'errors',[]);







    aModelName=slciConfig.getModelName();
    aReportFolder=slciConfig.getReportFolder();
    if(slcifeature('SlciDMR')==1)
        aDataSrc=fullfile(aReportFolder,[aModelName...
        ,'_verification_results']);
    else
        aDataSrc=fullfile(aReportFolder,[aModelName...
        ,'_verification_results.sldd']);
    end
    if~exist(aDataSrc,'file')
        DAStudio.error('Slci:slci:VerificationResultsError',aDataSrc);
    end





    dm=slci.results.SLCIDataManager(aModelName,aReportFolder);




    resultsReader=dm.getReader('RESULTS');
    reportTable.Status=resultsReader.getObject('Status');
    reportTable.verificationStatus=resultsReader.getObject('VerificationStatus');
    reportTable.traceabilityStatus=resultsReader.getObject('TraceabilityStatus');
    reportTable.utilsStatus=resultsReader.getObject('UtilsStatus');



    pMetaData=slci.internal.Profiler('SLCI','MetaData','','');

    incompReader=dm.getReader('INCOMPATIBILITY');
    ck=incompReader.getKeys();
    isfatal=false;

    incompMsgs={};
    for k=1:numel(ck)
        cObj=incompReader.getObject(ck{k});
        if cObj.getIsFatal()
            isfatal=true;
            if cObj.getHTMLEncode()



                incompMsgs{end+1}=slci.internal.encodeString(...
                cObj.getMessageString(),...
                'html',...
                'encode');%#ok
            else
                incompMsgs{end+1}=cObj.getMessageString();%#ok
            end
        end
    end


    if isfatal
        numIncomp=numel(incompMsgs);
        errors(numIncomp)=struct('errorMessage',[]);
        msg=message('Slci:slci:FATAL_INCOMPATIBILITY_HEADER',...
        aModelName);
        errors(1).errorMessage=msg.getString();
        for k=1:numIncomp
            errors(k+1).errorMessage=incompMsgs{k};
        end
        reportTable.errors=[errors,reportTable.errors];
        if slcifeature('IgnoreFatalIncompatibilities')~=1
            pMetaData.stop();
            return;
        end
    end



    errorReader=dm.getReader('ERROR');
    ek=errorReader.getKeys();
    if~isempty(ek)

        reportTable.errors=prepareError(ek,errorReader);
        if slcifeature('IgnoreFatalIncompatibilities')~=1
            pMetaData.stop();
            return;
        end
    end





    try
        reportTable.metaData=slci.report.prepareMetaData(slciConfig,dm);
    catch ex
        pMetaData.stop();

        DAStudio.error('Slci:report:ReportError');
    end

    pMetaData.stop();



    showVerification=slciConfig.getGenVerification();

    if showVerification

        pVerification=...
        slci.internal.Profiler('SLCI','Verification','','');

        try
            reportTable.statusData=...
            slci.report.processVerification(dm,reportConfig);
        catch ex

            pVerification.stop();
            DAStudio.error('Slci:report:ReportError');
        end
        pVerification.stop();
    end



    showTraceability=slciConfig.getGenTraceability();
    if showTraceability

        pTraceReport=...
        slci.internal.Profiler('SLCI','Traceability','','');
        try
            reportTable.trace=...
            slci.report.processTraceability(dm,reportConfig);
        catch ex
            pTraceReport.stop();

            DAStudio.error('Slci:report:ReportError');
        end
        pTraceReport.stop();
    end



    showUtils=slciConfig.getGenUtils();
    if showUtils
        pUtilsReport=...
        slci.internal.Profiler('SLCI','Utils','','');
        try
            reportTable.utils=...
            slci.report.processUtils(dm);
        catch ex
            pUtilsReport.stop();

            DAStudio.error('Slci:report:ReportError');
        end
        pUtilsReport.stop();
    end

end



function errors=prepareError(errorKeys,errorReader)
    errors=[];
    for k=1:numel(errorKeys)
        eObj=errorReader.getObject(errorKeys{k});
        thisError.errorMessage=eObj.getMessageString();
        errors=[errors,thisError];%#ok
    end
end
