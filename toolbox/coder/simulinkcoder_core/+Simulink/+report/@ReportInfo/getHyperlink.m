function out=getHyperlink(obj,text)
    narginchk(1,2)
    if nargin<2
        text=obj.getReportFileName;
    end
    out=sprintf('<a href="matlab:rtw.report.open(''%s'',''%s'')">%s</a>',obj.getRootSystem,coder.report.internal.str2StrVar(obj.BuildDirectory),text);
end
