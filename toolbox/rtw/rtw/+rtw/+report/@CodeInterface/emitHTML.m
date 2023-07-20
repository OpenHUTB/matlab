function txt=emitHTML(obj)




    if obj.PlatformType=="FunctionPlatform"


        p=rtw.report.ComponentInterface(obj.ModelName,obj.BuildDir);

        p.setLinkManager(obj.getLinkManager);
        p.Doc=Advisor.Document;

        p.execute;
        txt=p.emitHTML;
    else
        codeDescriptor=coder.internal.getCodeDescriptorInternal(obj.BuildDir,obj.ModelName,247362);
        codeInfo=codeDescriptor.getComponentInterface();
        expInports=codeDescriptor.getExpInports();
        temp=obj.getLinkManager;
        doc=coder.internal.codeinfo('getHTMLReport',codeInfo,expInports,temp.IncludeHyperlinkInReport,obj.BuildDir,obj);
        status=Simulink.report.ReportInfo.featureReportV2;
        if~status
            doc.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwreport_utils.js"></script>');
            doc.setBodyAttribute('ONLOAD',coder.internal.coderReport('getOnloadJS','rtwIdCodeInterface'));
        end
        doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
        txt=doc.emitHTML();
    end


