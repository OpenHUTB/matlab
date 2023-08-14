function generateReport(this,target)




    import dependencies.internal.report.GenerationStartedEventData
    import dependencies.internal.report.GenerationProgressEventData

    [~,fileName]=fileparts(target);
    notify(this,"GenerationStarted",...
    GenerationStartedEventData(fileName));
    doc=i_createReport(target);

    function requestCancelCallback(~,~)
        this.CancelRequested=true;
    end
    cancelListener=addlistener(this,"Cancel",@requestCancelCallback);

    createSectionFcns={...
    @()this.createTitleSection(doc.Type),...
    @()this.createFileListSection(doc.Type),...
    @()this.createProductListSection(doc.Type),...
    @()this.createSharedProductListSection(doc.Type),...
    @()this.createExternalToolboxesListSection(doc.Type)};

    for index=1:length(this.FileNodes)
        createSectionFcns{end+1}=...
        @()this.createFileDetailsFromIndex(index,doc.Type);%#ok<AGROW>
    end

    createSectionFcns{end+1}=@i_getLinkActivationScript;
    numSections=length(createSectionFcns);

    for index=1:numSections
        doc.append(createSectionFcns{index}());
        if this.CancelRequested
            doc.close();
            delete(target);
            return
        end
        notify(this,"GenerationProgress",...
        GenerationProgressEventData(index/numSections));
    end

    doc.close();
    delete(cancelListener);
    delete(this.DiagramFile);
    notify(this,"GenerationFinished");
end



function document=i_createReport(target)
    [fPath,name,ext]=fileparts(target);
    if name==""
        error(message("MATLAB:dependency:report:NoFileName"))
    end

    name=fullfile(fPath,name);
    if ext==".docx"||ext==".pdf"
        format=strrep(ext,".","");
    else
        format="html-file";
        if ext~=".html"
            name=name+ext;
        end
    end
    document=dependencies.internal.report.DependencyAnalyzerReport(name,format);
end


function script=i_getLinkActivationScript()
    scriptPath=fullfile(...
    matlabroot,"toolbox","matlab","dependency","report",...
    "script","activateMatlabLinks.js");
    scriptText=fileread(scriptPath);
    script=mlreportgen.dom.RawText(...
    strcat('<script>',scriptText,'</script>'));
end
