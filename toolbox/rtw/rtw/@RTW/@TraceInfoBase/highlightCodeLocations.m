function varargout=highlightCodeLocations(h,locs)




    nargoutchk(0,1);

    if~exist(h.BuildDir,'dir')
        DAStudio.error('RTW:traceInfo:buildDirNotFound',h.BuildDir,h.Model);
    end

    htmlrpt=h.getCodeGenRptFullPathName;
    sep='?';

    if~iscell(locs)
        locs={locs};
    end

    files={};
    lines={};
    for j=1:length(locs)
        loc=locs{j};
        for k=1:length(loc)
            [~,name,ext]=fileparts(loc(k).file);
            filename=[name,ext];
            fidx=find(strcmp(filename,files));
            if isempty(fidx)
                files{end+1}=filename;%#ok
                fidx=length(files);
                lines{end+1}=[];%#ok
            end
            lines{fidx}=[lines{fidx},loc(k).line];%#ok
        end
    end
    query='';
    for j=1:length(files)
        if isempty(query)
            query=sprintf('%s:',files{j});
        else
            query=sprintf('%s&%s:',query,files{j});
        end
        currLines=sort(lines{j});
        for k=1:length(currLines)
            if k==1
                comma='';
            else
                comma=',';
            end
            query=sprintf('%s%s%d',query,comma,currLines(k));
        end
    end

    if~isempty(query)
        arg='';
        if~isempty(h.HighlightColor)
            arg=[arg,'&color=',h.HighlightColor];
        end
        if~isempty(h.FontSize)
            arg=[arg,'&fontsize=',h.FontSize];
        end
        query=[sep,query,arg];
    end
    fileURL=Simulink.document.fileURL(htmlrpt,query);
    if nargout>=1
        varargout{1}=fileURL;
        return;
    end
    if h.UseWidget


        if length(fileURL)>=2083
            MSLDiagnostic('RTW:traceInfo:tooManyLines').reportAsWarning;
        end
    end

    title=h.getTitle;
    if~isempty(query)
        fileURL=[fileURL,'&model2code_src=model'];
    end
    rtw.report.ReportInfo.openURL(fileURL,title,h.HelpMethod);


