function showFullReport(obj,varargin)





    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        input=varargin{1};
        src=simulinkcoder.internal.util.getSource(input);
    end

    mdl=src.modelName;
    if isempty(mdl)
        return;
    end

    url=obj.getUrl(mdl);
    url=[url,'&type=full'];
    cef=matlab.internal.webwindow(url);
    cef.Title='Code Generation Report';
    cef.show();
