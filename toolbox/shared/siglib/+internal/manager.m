function varargout=manager(key,action,handleObject)











    mlock;
    persistent handleMap;

    key=genvarname(key);

    switch action
    case 'remove'
        if isfield(handleMap,key)
            handleMap.(key)=setdiff(handleMap.(key),handleObject);
        end
    case 'add'
        if isfield(handleMap,key)
            newValue=[handleMap.(key),handleObject];
        else
            newValue=handleObject;
        end
        handleMap.(key)=newValue;
    case 'get'
        if isfield(handleMap,key)
            varargout{1}=handleMap.(key);
        else
            varargout{1}=[];
        end
    end


