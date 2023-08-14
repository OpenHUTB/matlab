function out=getReportInfo(sys,varargin)





















    out=[];
    fromMat=true;

    if isValidSlObject(slroot,sys)&&nargin<=2
        model=bdroot(sys);
        out=rtw.report.ReportInfo.instance(model);
        fromMat=false;

        if isa(out,'rtw.report.ReportInfo')

            if~out.isValidateReportInfo(sys,varargin{:})
                out=[];
            end
        end
    end


    if~isa(out,'rtw.report.ReportInfo')||nargin>2
        try
            out=rtw.report.ReportInfo.loadMat(sys,varargin{:});
            fromMat=true;
        catch ME
            out=[];


            if nargin==1&&slfeature('CommentOffTrace')==1
                try
                    [model,remain]=strtok(sys,':/');
                    if remain==""
                        out=rtw.report.getLatestSubsysBuildReportInfo(model);
                        fromMat=true;
                    end
                catch
                    out=[];
                end
            end


            if isempty(out)
                rethrow(ME);
            end
        end
    end

    if isValidSlObject(slroot,sys)&&length(out)==1
        out.link(bdroot(sys),fromMat);
    end
    for i=1:length(out)
        out(i).initStartDirBasedOnBuildDir;
    end

