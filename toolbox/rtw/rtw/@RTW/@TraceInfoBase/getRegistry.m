function out=getRegistry(h,varargin)



    out=[];

    if~h.isReady&&isempty(h.Registry)


        DAStudio.error('RTW:traceInfo:notReady');
    end

    narginchk(1,4);
    needMergeAllInlineTrace=true;
    if nargin==4
        assert(strcmp(varargin{2},'NeedMergeAllInlineTrace'));
        needMergeAllInlineTrace=varargin{3};
    end

    if needMergeAllInlineTrace&&~h.inlineTraceIsMerged&&isa(h,'RTW.TraceInfo')
        h.mergeInlineTrace();
    end



    if(~isa(h,'RTW.TraceInfo')||(~rtw.report.ReportInfo.featureReportV2&&isa(h,'RTW.TraceInfo')))...
        &&h.CheckModelTimeStamp
        if h.ModifiedTimeStamp>0...
            &&get_param(h.Model,'RTWModifiedTimeStamp')>h.ModifiedTimeStamp
            warnId='RTW:traceInfo:modelChanged';
            if~strcmp(h.getLastWarningId,warnId)
                h.LastWarning={warnId};
                MSLDiagnostic(warnId).reportAsWarning;
            end
        end
    end

    if nargin==1
        out=h.Registry;
        return
    end

    block=varargin{1};
    sid='';
    nl=newline;
    if~ischar(block)||contains(block,'/')


        try
            sid=Simulink.ID.getSID(block);
        catch
        end
    else

        sid=block;
    end
    if h.RegistrySidMap.isKey(sid)
        idx=h.RegistrySidMap(sid);
        out=h.Registry(idx);



        if(isempty(out.location)&&~isempty(Simulink.ID.checkSyntax(sid)))||...
            (ischar(block)&&~strcmp(block,sid)&&~isempty(out.pathname)&&...
            ~strcmp(strrep(block,nl,' '),strrep(out.pathname,nl,' ')))
            out=[];
        end
        return
    end


    if~ischar(block)||contains(block,'/')
        if~ischar(block)
            block=getfullname(varargin{1});
        end

        block=strrep(block,nl,' ');
        idx=arrayfun(@(x)strcmp(strrep(x.pathname,nl,' '),block),h.Registry);
        out=h.Registry(idx);
    end


