function highlight(obj,blocks)



    if isempty(blocks)
        return;
    end
    if ischar(blocks)
        blocks={blocks};
    end

    for i=1:length(blocks)
        if~ischar(blocks{i})||~isempty(strfind(blocks{i},'/'))
            blocks{i}=Simulink.ID.getSID(blocks{i});
        end
    end

    if length(blocks)==1
        sidStr=blocks{1};
    else
        sidStr=strjoin(blocks,',');
    end

    fileURL=Simulink.document.fileURL(obj.getReportFileFullName,['?sid=',sidStr,'&model2code_src=model']);
    title=DAStudio.message('RTW:report:DocumentTitle','');
    if obj.featureOpenInStudio
        obj.openInStudio(fileURL);
    else
        Simulink.report.ReportInfo.openURL(fileURL,title,obj.getHelpMethod,false);
    end
end


