function onCodeGenStart(~,varargin)







    bd=varargin{1};
    mdl=bd.Name;

    cr=simulinkcoder.internal.Report.getInstance;
    cr.lock(mdl);