function df=createDocumentFragment(d,varargin)






    if rptgen.use_java
        df=javaMethod('createDocumentFragment',...
        java(d));
    else
        df=createDocumentFragment(d.Document);
    end

    for i=1:length(varargin)
        if~isempty(varargin{i})
            if rptgen.use_java
                df.appendChild(d.createTextNode(varargin{i}));
            else
                appendChild(df,createTextNode(d,varargin{i}));
            end

        end
    end