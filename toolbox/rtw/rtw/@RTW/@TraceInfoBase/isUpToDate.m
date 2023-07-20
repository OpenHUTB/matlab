function[out,reason,args]=isUpToDate(h,varargin)




    out=false;
    reason='';
    args={};

    n=length(h.GeneratedFiles);
    if nargin>=2
        for k=1:nargin-1
            switch varargin{k}
            case '-nofilecheck'
                n=0;
            otherwise
                DAStudio.error('RTW:utility:invalidInputArgs',varargin{k});
            end
        end
    end

    if(h.CheckTimeStampOneFileOnly)
        n=1;
    end


    if isempty(h.BuildDir)||isempty(h.BuildDirRoot)
        reason='RTW:traceInfo:notReady';
        return;
    end


    tinfoName=fullfile(h.BuildDirRoot,h.getTraceInfoFileName);
    if~exist(tinfoName,'file')
        reason='RTW:traceInfo:notGenerated';
        return
    end

    currModelFile=get_param(h.Model,'FileName');
    if~strcmp(currModelFile,h.ModelFileNameAtBuild)
        reason='RTW:traceInfo:modelDirNotMatch';
        args={currModelFile,h.ModelFileNameAtBuild};
        return
    end

    if h.CheckModelTimeStamp==true
        modelTs=get_param(h.Model,'RTWModifiedTimeStamp');
        if modelTs<h.ModifiedTimeStamp

            reason='RTW:traceInfo:modelUnsaved';
            return
        end
        if modelTs>h.TimeStamp

            reason='RTW:traceInfo:modelChanged';
            return
        end
    end



    if strcmpi(get_param(h.Model,'GenerateComments'),'on')
        for k=1:n
            [~,filename,ext]=fileparts(h.GeneratedFiles{k});
            file=fullfile(h.BuildDir,[filename,ext]);
            if~exist(file,'file')
                reason='RTW:traceInfo:srcNotFound';
                return
            end
            [str,ignore]=h.getCodeTimeStamp(file);
            if ignore==true,continue,end
            ts=rtwprivate('convertTimeStamp',str);
            if ts==0
                reason='RTW:traceInfo:srcTimeStampNotFound';
                return
            end
            if ts~=h.TimeStamp
                reason='RTW:traceInfo:srcTimeStampNotMatch';
                return
            end
        end




        if~rtw.report.ReportInfo.featureReportV2
            for k=1:n
                [~,filename,ext]=fileparts(h.GeneratedFiles{k});
                htmlfile=fullfile(h.BuildDir,h.getCodeGenRptDir,[filename,'_',ext(2:end),'.html']);
                if~exist(htmlfile,'file')
                    reason='RTW:traceInfo:htmlNotFound';
                    return
                end
                [str,ignore]=h.getCodeTimeStamp(htmlfile);
                if ignore==true,continue,end
                ts=rtwprivate('convertTimeStamp',str);
                if ts~=h.TimeStamp
                    reason='RTW:traceInfo:htmlTimeStampNotMatch';
                    return
                end
            end
        end
    end
    out=true;


