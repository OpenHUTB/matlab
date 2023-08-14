
function[dm,status]=generateReport(slciConfig,...
    reportConfig)

    Model=slciConfig.getModelName();



    pFormatReport=slci.internal.Profiler('SLCI','FormatReport',Model,'');
    try
        [dm,ReportData]=slci.report.processReport(slciConfig,...
        reportConfig);
    catch exception
        pFormatReport.stop();
        rethrow(exception)
    end
    status=ReportData.Status;
    pFormatReport.stop();



    pEmitHtml=slci.internal.Profiler('SLCI','EmitHtml',Model,'');

    content=slci.ReportContent(ReportData);
    content.showTraceability=slciConfig.getGenTraceability();
    content.showVerification=slciConfig.getGenVerification();


    content.makeReportContent(slciConfig,Model);
    Section=content.Section;


    modelFileName=dm.getMetaData('ModelFileName');

    [~,fileName,fileExt]=fileparts(modelFileName);
    modelName=[fileName,fileExt];

    Title=['Simulink Code Inspector Report for ',modelName];
    ModelLink=slci.internal.ReportUtil.createModelLink(modelFileName,modelName);
    TitleSection=['Simulink Code Inspector Report for ',ModelLink];

    Header='<!DOCTYPE html>\n';
    Header=[Header,'<html>\n'];
    Header=[Header,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >\n'];
    Header=[Header,'<head>\n'];


    Css=slci.internal.ReportUtil.genCSS(reportConfig);
    Header=[Header,Css];



    Script=slci.internal.ReportUtil.genScript();
    Header=[Header,Script];


    Header=[Header,'<title>',Title,'</title>'];
    Header=[Header,'</head>\n'];

    BodyBegin='<body>\n';
    BodyEnd='</body></html>\n';

    htmlReportFile=slciConfig.getReportFile();
    Fid=fopen(htmlReportFile,'w','n','utf-8');
    fprintf(Fid,Header);
    fprintf(Fid,BodyBegin);

    Caption=['<div style="text-align:center"> '...
    ,slci.internal.ReportUtil.makeHeader2(TitleSection)...
    ,'</div>'];
    fprintf(Fid,Caption);

    fprintf(Fid,'<hr>\n');
    fprintf(Fid,Section);


    fprintf(Fid,BodyEnd);
    fclose(Fid);

    pEmitHtml.stop();

end


