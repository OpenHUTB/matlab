function out=getMostRecentBuildDir(h)





    dirs=RTW.getBuildDir(h.Model);
    dirRoot=dirs.CodeGenFolder;
    sinfomat=fullfile(dirRoot,h.getSInfoFileName);
    ts=[];
    if exist(sinfomat,'file')
        sinfo=load(sinfomat);

        ts=arrayfun(@(x)(datenum(x.TimeStamp)*...
        logical(exist(fullfile(x.buildDir,...
        h.getCodeGenRptDir,...
        'traceInfo.mat'),...
        'file'))),...
        sinfo.infoStruct.Subsystems);
    end
    numSubsys=length(ts);

    tinfo=fullfile(dirRoot,h.getTraceInfoFileName);
    if exist(tinfo,'file')
        ts(end+1)=datenum(rtwprivate('getFileTimeStamp',tinfo));
    end
    if isempty(ts)
        out='';
    else
        [~,idx]=max(ts);
        if ts(idx)==0
            out='';
        elseif idx<=numSubsys
            out=sinfo.infoStruct.Subsystems(idx).buildDir;
        else

            out=fullfile(dirRoot,h.RelativeBuildDir);
        end
    end
