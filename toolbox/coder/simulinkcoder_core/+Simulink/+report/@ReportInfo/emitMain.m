function emitMain(obj,filename)



    model=obj.ModelName;
    if isempty(obj.SourceSubsystem)
        rptModel=obj.ModelName;
    else
        rptModel=obj.SourceSubsystem;
    end

    if(nargin<2)
        filename=obj.getReportFileFullName;
    end

    if Simulink.report.ReportInfo.featureReportV2&&(obj.featureWebview2()&&obj.hasWebview())&&isa(obj,'rtw.report.ReportInfo')
        locEmitMainWebView2V2(obj,model,rptModel,filename);
    elseif(obj.featureWebview2()&&obj.hasWebview())
        locEmitMainWebView2(obj,model,rptModel,filename);
    else
        locEmitMain(obj,model,rptModel,filename);
    end

end

function locEmitMainWebView2V2(obj,~,~,filename)



    webViewHtmlHeader=getEmittedHtmlWebView2V2(obj);


    fid=fopen(filename);
    if fid==-1
        return;
    end
    txtCell=textscan(fid,'%s');
    txtStr=txtCell{1};
    indexHtmlTxt=strjoin(txtStr);
    fclose(fid);


    mergedHtmlTxt=indexHtmlTxt;
    regStr="(<script.+</script>)";
    cap=regexp(webViewHtmlHeader,regStr,'tokens');
    cap=cap{1};
    scriptStr=cap{1};


    mergedHtmlTxt=strrep(mergedHtmlTxt,'</head>',[scriptStr,newline,'</head>']);


    beforeStr='<iframe id="rtw_webview" height="100%" width="100%" src="" style="display: none;"></iframe>';
    afterStr='<iframe id="rtw_webview" height="100%" width="100%" src="" style="display: initial;" onload="webviewToCodeInit()"></iframe>';
    mergedHtmlTxt=strrep(mergedHtmlTxt,beforeStr,afterStr);



    fileattrib(filename,'+w')
    fid=fopen(filename,'w','n','utf-8');
    fprintf(fid,'%s',mergedHtmlTxt);
    fclose(fid);
end

function locEmitMainWebView2(obj,model,rptModel,filename)
    outHtml=getEmittedHtmlWebView2(obj,model,rptModel,filename);
    fid=fopen(filename,'w','n','utf-8');
    fwrite(fid,outHtml,'char');
    fclose(fid);
end

function locEmitMain(obj,model,rptModel,filename)
    document=ModelAdvisor.Document;
    title=DAStudio.message('RTW:report:DocumentTitle',model);
    document.addHeadItem('<meta http-equiv="X-UA-Compatible" content="IE=edge" >');
    document.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
    document.setTitle(title);
    document.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
    if obj.hasWebview
        document.addHeadItem('<script language="JavaScript" type="text/javascript" src="slwebview.js"></script>');
        document.addHeadItem('<script language="JavaScript" type="text/javascript" src="id_mapping.js"></script>');
    end
    document.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwhilite.js"></script>');
    document.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwshrink.js"></script>');
    document.addHeadItem(['<script language="JavaScript" type="text/javascript">var reportModel = "',rptModel,'"; </script>']);
    document.addHeadItem(['<script type="text/javascript">var TargetLang = "',obj.TargetLang,'"; </script>']);

    if strcmp(obj.Config.GenerateTraceInfo,'on')||strcmp(obj.Config.IncludeHyperlinkInReport,'on')
        document.addHeadItem(['<script language="JavaScript" type="text/javascript" src="',obj.ModelName,'_traceInfo.js"></script>']);
        document.addHeadItem('<script language="JavaScript" type="text/javascript" src="requirements.js"></script>');
    end
    if strcmp(obj.Config.GenerateTraceInfo,'on')||(obj.hasWebview&&strcmp(obj.Config.IncludeHyperlinkInReport,'on'))
        document.addHeadItem(['<script language="JavaScript" type="text/javascript" src="',obj.ModelName,'_sid_map.js"></script>']);
    end

    document.addHeadItem('<script language="JavaScript" type="text/javascript" src="define.js"></script>');
    document.addHeadItem('<script language="JavaScript" type="text/javascript" src="traceInfo_flag.js"></script>');

    baseName=[model,obj.getModelNameSuffix];
    codeNavFrame=locCreateFrame([baseName,'_contents.html'],'rtwreport_contents_frame');
    onLoadFxnForContents=sprintf('loadDocFrameSource(''%s'')',baseName);
    codeNavFrame.setAttribute('onLoad',onLoadFxnForContents);
    surveyFile='';
    codeFrame=locCreateFrame(surveyFile,'rtwreport_document_frame');
    codeFrame.setAttribute('style','background-color: white;');
    navFrame=locCreateFrame('nav.html','rtwreport_nav_frame');
    navFrame.setAttribute('scrolling','no');
    navFrame.setAttribute('noresize','noresize');
    navToolbarFrame=locCreateFrame('navToolbar.html','rtwreport_navToolbar_frame');
    navToolbarFrame.setAttribute('scrolling','no');
    navToolbarFrame.setAttribute('noresize','noresize');
    inspectFrame=locCreateFrame('inspect.html','rtwreport_inspect_frame');
    inspectFrame.setAttribute('scrolling','no');
    inspectFrame.setAttribute('noresize','noresize');

    borderSize='2';
    if obj.hasWebview()





        [~,fname]=fileparts(obj.WebviewFileName);
        modelNavFrame=locCreateFrame('explorer.html',[fname,'_explorer']);
        modelFrame=locCreateFrame('model.html',[fname,'_model']);
        webFrame=locCreateFrame('',[fname,'_web']);
        modelFrameset=ModelAdvisor.Frameset;
        modelFrameset.setAttribute('rows','100%,0%');
        modelFrameset.setAttribute('id',[fname,'_frame']);
        modelFrameset.setAttribute('name',[fname,'_frame']);
        modelFrameset.addFrameItem(modelFrame);
        modelFrameset.addFrameItem(webFrame);
        webviewFrameset=ModelAdvisor.Frameset;
        webviewFrameset.setAttribute('cols','20%,80%');
        webviewFrameset.setAttribute('id','rtw_webview_frameset');
        webviewFrameset.addFrameItem(modelNavFrame);
        webviewFrameset.addFrameItem(modelFrameset)
        midFrameset=ModelAdvisor.Frameset;
        midFrameset.setAttribute('rows','50%,50%');
        midFrameset.addFrameItem(codeFrame);
        midFrameset.addFrameItem(webviewFrameset);
        midFrameset.setAttribute('id','rtw_webviewMidFrame');
        document.Frameset.setAttribute('cols','25%,75%');
        document.addFrameItem(codeNavFrame);
        document.addFrameItem(midFrameset);
        document.FramesetItem.setAttribute('id','rtw_report_frameset');
    else





        midFrameset=ModelAdvisor.Frameset;

        midFrameset.setAttribute('rows','0%,100%,0%');
        midFrameset.addFrameItem(navToolbarFrame);
        midFrameset.addFrameItem(codeFrame);
        midFrameset.addFrameItem(inspectFrame);
        midFrameset.setAttribute('id','rtw_midFrame');
        if Simulink.report.ReportInfo.featureOpenInStudio
            colStretch='25%,100%,0%';
            mainFrameset=ModelAdvisor.Frameset;
            mainFrameset.setAttribute('cols',colStretch);
            mainFrameset.setAttribute('id','main');
            mainFrameset.setAttribute('border',borderSize);
            mainFrameset.addFrameItem(codeNavFrame);
            mainFrameset.addFrameItem(midFrameset);
            mainFrameset.addFrameItem(navFrame);
            document.Frameset.setAttribute('rows','0%,100%');
            fileSelectorFrame=ModelAdvisor.Frame;
            fileSelectorFrame.setAttribute('scrolling','no');
            fileSelectorFrame.setSrc('fileSelector.html');
            fileSelectorFrame.setAttribute('name','fileSelector');
            fileSelectorFrame.setAttribute('id','fileSelector');
            document.Frameset.addFrameItem(fileSelectorFrame);
            document.Frameset.addFrameItem(mainFrameset);
            document.Frameset.setAttribute('id','whole');
        else
            colStretch='25%,75%,0%';
            document.Frameset.setAttribute('cols',colStretch);
            document.Frameset.setAttribute('id','main');
            document.Frameset.setAttribute('border',borderSize);
            document.Frameset.addFrameItem(codeNavFrame);
            document.Frameset.addFrameItem(midFrameset);
            document.Frameset.addFrameItem(navFrame);
        end
    end

    fid=fopen(filename,'w','n','utf-8');
    fwrite(fid,document.emitHTML,'char');
    fclose(fid);
end

function out=locCreateFrame(src,name)
    out=ModelAdvisor.Frame;
    out.setAttribute('scrolling','auto');
    if~isempty(src)
        out.setSrc(src);
    end
    out.setAttribute('name',name);
    out.setAttribute('id',name);
end

function outStr=getEmittedHtmlWebView2(obj,model,rptModel,filename)

    document=ModelAdvisor.Document;
    title=DAStudio.message('RTW:report:DocumentTitle',model);
    document.addHeadItem('<meta http-equiv="X-UA-Compatible" content="IE=edge" />');
    document.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
    document.setTitle(title);
    document.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
    document.addHeadItem('<script type="text/javascript" src="rtwhilite.js"></script>');
    document.addHeadItem('<script type="text/javascript" src="rtwshrink.js"></script>');
    document.addHeadItem(['<script type="text/javascript">var reportModel = "',rptModel,'"; </script>']);
    document.addHeadItem(['<script type="text/javascript">var TargetLang = "',obj.TargetLang,'"; </script>']);


    document.addHeadItem('<script type="text/javascript" src="webview_codegen.js"></script>');

    if strcmp(obj.Config.GenerateTraceInfo,'on')||strcmp(obj.Config.IncludeHyperlinkInReport,'on')
        document.addHeadItem(['<script type="text/javascript" src="',obj.ModelName,'_traceInfo.js"></script>']);
        document.addHeadItem('<script type="text/javascript" src="requirements.js"></script>');
    end
    if strcmp(obj.Config.GenerateTraceInfo,'on')||(obj.hasWebview&&strcmp(obj.Config.IncludeHyperlinkInReport,'on'))
        document.addHeadItem(['<script type="text/javascript" src="',obj.ModelName,'_sid_map.js"></script>']);
    end

    document.addHeadItem('<script type="text/javascript" src="define.js"></script>');
    document.addHeadItem('<script type="text/javascript" src="traceInfo_flag.js"></script>');

    baseName=[model,obj.getModelNameSuffix];
    codeNavFrame=locCreateFrame([baseName,'_contents.html'],'rtwreport_contents_frame');
    surveyFile='';
    codeFrame=locCreateFrame(surveyFile,'rtwreport_document_frame');
    codeFrame.setAttribute('style','background-color: white;');
    navFrame=locCreateFrame('nav.html','rtwreport_nav_frame');
    navFrame.setAttribute('scrolling','no');
    navFrame.setAttribute('noresize','noresize');
    navToolbarFrame=locCreateFrame('navToolbar.html','rtwreport_navToolbar_frame');
    navToolbarFrame.setAttribute('scrolling','no');
    navToolbarFrame.setAttribute('noresize','noresize');
    inspectFrame=locCreateFrame('inspect.html','rtwreport_inspect_frame');
    inspectFrame.setAttribute('scrolling','no');
    inspectFrame.setAttribute('noresize','noresize');






    htmlDir=fileparts(filename);
    webviewUrl=strrep(obj.WebviewFileName(numel(htmlDir)+2:end),'\','/');
    webviewFrame=locCreateFrame(webviewUrl,'rtw_webview');
    webviewFrame.setAttribute('onload','webviewToCodeInit()');

    midFrameset=ModelAdvisor.Frameset;
    midFrameset.setAttribute('rows','50%,50%');
    midFrameset.setAttribute('id','rtw_webviewMidFrame');
    midFrameset.addFrameItem(codeFrame);
    midFrameset.addFrameItem(webviewFrame);

    document.Frameset.setAttribute('cols','25%,75%');
    document.addFrameItem(codeNavFrame);
    document.addFrameItem(midFrameset);
    document.FramesetItem.setAttribute('id','rtw_report_frameset');

    outStr=document.emitHTML;
end

function outStr=getEmittedHtmlWebView2V2(obj)


    document=ModelAdvisor.Document;

    rptModel=obj.ModelName;

    document.addHeadItem('<link rel="stylesheet" type="text/css" href="pages/rtwreport.css" />');
    document.addHeadItem('<script type="text/javascript" src="pages/rtwhilite2.js"></script>');
    document.addHeadItem('<script type="text/javascript" src="pages/rtwshrink.js"></script>');
    document.addHeadItem(['<script type="text/javascript">var reportModel = "',rptModel,'"; </script>']);
    document.addHeadItem(['<script type="text/javascript">var TargetLang = "',obj.TargetLang,'"; </script>']);
    if obj.hasWebview
        document.addHeadItem('<script type="text/javascript">window.hasWebview = true;</script>');
    else
        document.addHeadItem('<script type="text/javascript">window.hasWebview = false;</script>');
    end

    document.addHeadItem('<script type="text/javascript" src="pages/webview_codegen.js"></script>');

    if strcmp(obj.Config.GenerateTraceInfo,'on')||strcmp(obj.Config.IncludeHyperlinkInReport,'on')
        document.addHeadItem(['<script type="text/javascript" src="pages/',obj.ModelName,'_traceInfo.js"></script>']);

    end
    if strcmp(obj.Config.GenerateTraceInfo,'on')||(obj.hasWebview&&strcmp(obj.Config.IncludeHyperlinkInReport,'on'))
        document.addHeadItem(['<script type="text/javascript" src="pages/',obj.ModelName,'_sid_map.js"></script>']);
    end

    outStr=document.emitHTML;
end



