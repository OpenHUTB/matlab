classdef ReqDummyPart<slreq.report.ReportPart

    methods

        function part=ReqDummyPart(p1)
            part=part@slreq.report.ReportPart(p1,'SLReqEmptyPart');
        end

        function fill(this)
            endBookMark=slreq.report.utils.getLinkTargetString(num2str(tic));
            linkTarget=mlreportgen.dom.LinkTarget(endBookMark);
            linkTarget.StyleName='Normal';
            append(this,linkTarget);
        end
    end
end
