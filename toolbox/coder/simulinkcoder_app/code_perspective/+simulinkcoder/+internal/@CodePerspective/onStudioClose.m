function onStudioClose(obj,varargin)



    st={};
    for i=1:length(obj.st)
        s=obj.st{i};
        if s.isvalid
            st{end+1}=s;%#ok<AGROW>
        end
    end
    obj.st=st;


    ls={};
    for i=1:length(obj.listeners)
        l=obj.listeners{i};
        if l.Source{1}.isvalid
            ls{end+1}=l;%#ok<AGROW>
        end
    end
    obj.listeners=ls;