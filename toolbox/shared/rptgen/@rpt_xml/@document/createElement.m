function rgElement=createElement(d,tagName,varargin)








    if rptgen.use_java
        rgElement=javaMethod('createElement',...
        java(d),...
        tagName);
    else
        rgElement=createElement(d.Document,tagName);
    end

    for i=1:length(varargin)
        appendChild(rgElement,createTextNode(d,varargin{i}));
    end
