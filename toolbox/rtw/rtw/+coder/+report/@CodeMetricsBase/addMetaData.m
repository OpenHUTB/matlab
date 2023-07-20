function addMetaData(obj)



    ccm=obj.Data;
    js=obj.getOnloadJSFcn();
    if~isempty(js)
        obj.setOnloadFcn(js);
    end

    obj.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
    if~obj.InReportInfo||~strcmp(obj.ReportFolder,fullfile(ccm.BuildDir,'html'))
        obj.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwshrink.js"></script>');


        if obj.slFeatureReportV2
            obj.addHeadItem(['<script>',coder.report.internal.getPostParentWindowMessageDef,'</script>']);
        end
        jsfile=fullfile(matlabroot,'toolbox','shared','codergui','web','resources','rtwshrink.js');
        if isempty(obj.ReportFolder)


            str=fileread(jsfile);
            obj.Doc.addHeadItem(sprintf('<script language="JavaScript" type="text/javascript" ><!--\n%s//-->\n</script>\n',str));
        else
            dstfile=fullfile(obj.ReportFolder,'rtwshrink.js');
            coder.internal.coderCopyfile(jsfile,dstfile);
        end
    end
end


