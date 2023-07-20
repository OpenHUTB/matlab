function[parent,name]=pathParts(diagramPath)















    aPath=char(diagramPath);
    parent='';
    name='';


    i=length(aPath);
    while((i>1)&&isempty(parent))
        if(aPath(i)=='/')
            if(aPath(i-1)=='/')
                i=i-2;
            else
                parent=aPath(1:i-1);
                name=aPath(i+1:end);
            end
        else
            i=i-1;
        end
    end

    if isempty(parent)
        name=aPath;
    end

    parent=string(parent);
    name=string(name);
end
