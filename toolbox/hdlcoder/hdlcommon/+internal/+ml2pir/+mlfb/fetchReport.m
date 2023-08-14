function report=fetchReport(blockPath)





    blockH=get_param(blockPath,'handle');

    chartH=internal.ml2pir.mlfb.getChartHandle(blockPath);
    chartId=chartH.Id;

    ignoreErr=true;
    sf('SelectChartIDCInfoByMachine',chartId,bdroot(blockPath));
    MATLABFunctionBlockSpecializationCheckSum=sf('SFunctionSpecialization',chartId,blockH,ignoreErr);

    report=cgxe('getInferenceReport',MATLABFunctionBlockSpecializationCheckSum);



    if isempty(report)
        report=readReportFromFile(MATLABFunctionBlockSpecializationCheckSum,...
        chartH);
    end
end

function report=readReportFromFile(checksum,chartH)
    [~,mainInfoName,~,~]=sfprivate('get_report_path',pwd,checksum,false);
    if~exist(mainInfoName,'file')



        modeldir=fileparts(chartH.Machine.FullFileName);
        reportDir=fullfile(sfprivate('get_sf_proj',modeldir),...
        'EMLReport');
        mainInfoName=fullfile(reportDir,...
        [checksum,'.mat']);
    end

    load(mainInfoName,'report');
    report=report.inference;
end


