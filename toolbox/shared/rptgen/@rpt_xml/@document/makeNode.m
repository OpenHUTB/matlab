function n=makeNode(d,v,varargin)










    if rptgen.use_java
        nodeClassName='org.w3c.dom.Node';
    else
        nodeClassName='matlab.io.xml.dom.Node';
    end

    if isa(v,nodeClassName)
        n=v;
        return;






    elseif isempty(v)
        n=createDocumentFragment(d);


    elseif isCellVector(v)
        n=d.createElement('simplelist');
        n.setAttribute('type','vert');
        n.setAttribute('columns','1');
        for cellIdx=1:length(v)



            n.appendChild(d.createElement('member',...
            d.createTextNode(v{cellIdx},varargin{:})));
        end
    else

        if isempty(varargin)
            varargin={0};
        end
        s=rptgen.toString(v,varargin{:});


        if rptgen.use_java
            n=com.mathworks.toolbox.rptgencore.docbook.StringImporter.importHonorLineBreaks(java(d),s);
        else
            n=mlreportgen.re.internal.db.StringImporter.importHonorLineBreaks(d.Document,s);
        end
    end


    function tf=isCellVector(v)

        if iscell(v)
            siz=size(v);
            if length(siz)<3
                if min(siz)==1
                    tf=true;
                    return;
                end
            end
        end
        tf=false;

