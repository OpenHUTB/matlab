function code2model(sys,file,location,varargin)


    [licenseCheck,MissingLicense]=rtw.report.checkOutLicenseForTraceability();

    if~licenseCheck
        DAStudio.error('RTW:report:Code2ModelLicenseError',strjoin(MissingLicense,', '));
    end


    model=strtok(sys,':');
    if~isempty(model)
        rtw.report.load_model_before_code2model(model,varargin{:});
    else
        return;
    end

    rptInfo=rtw.report.getReportInfo(sys);
    traceInfo=coder.trace.getTraceInfoByReportInfo(rptInfo);

    if isempty(rptInfo)||isempty(traceInfo)
        return;
    end

    lineCol=sscanf(location,'%dc%d');
    if numel(lineCol)==1
        sids=traceInfo.getSidsForLine(file,lineCol);
    else
        [~,f,ext]=fileparts(file);
        if strcmp(ext,'.html')||isempty(ext)
            idx=strfind(f,'_');
            f(idx(end))='.';
        else
            f=file;
        end
        c2m=traceInfo.getCodeToModel(f,lineCol(1),lineCol(2));
        sids=c2m.modelElems;
    end


    input_sids=sids;
    if~isempty(rptInfo.SourceSubsystem)
        for i=1:length(sids)
            sids{i}=Simulink.ID.getSubsystemBuildSID(sids{i},...
            rptInfo.SourceSubsystem);
        end

        sids=sids(~cellfun(@isempty,sids));
    end
    for i=1:length(sids)
        sid=sids{i};
        if isletter(sid(1))
            continue;
        end
        pos=strfind(sid,':');
        if isempty(pos)
            continue;
        end
        pos=pos(1);
        prefix=str2double(extractBefore(sid,pos));
        if isempty(prefix)||isnan(prefix)
            continue;
        end
        stem=extractAfter(sid,pos);
        sids{i}=[traceInfo.sidPrefixes{prefix+1},':',stem];
    end
    if~isempty(rptInfo.SourceSubsystem)&&isempty(sids)&&~isempty(input_sids)
        DAStudio.error('RTW:traceInfo:blockNotInModel',input_sids{1});
    end
    coder.internal.highlightBlocks(sids,varargin{:});

end


