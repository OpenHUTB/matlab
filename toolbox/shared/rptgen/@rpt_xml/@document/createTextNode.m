function tNode=createTextNode(d,textContent,varargin)





    if rptgen.use_java
        nodeClassName='org.w3c.dom.Node';
    else
        nodeClassName='matlab.io.xml.dom.Node';
    end

    if isa(textContent,nodeClassName)
        tNode=textContent;
    else
        if isempty(varargin)
            varargin={0};
        end

        txt=rptgen.toString(textContent,varargin{:});
        if rptgen.use_java
            tNode=javaMethod('createTextNode',java(d),txt);
        else
            tNode=createTextNode(d.Document,txt);
        end
    end

