function varargout=embeddedObjCache(method,modelH,value)

    persistent EmbeddedObjArrays
    mlock;
    if isempty(EmbeddedObjArrays)
        EmbeddedObjArrays=containers.Map('KeyType','double','ValueType','any');
    end

    if nargin>1&&ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end

    switch method
    case 'get'
        if~isKey(EmbeddedObjArrays,modelH)
            varargout{1}={};
        else
            varargout{1}=EmbeddedObjArrays(modelH);
        end

    case 'set'

        EmbeddedObjArrays(modelH)=value;

    case 'remove'
        if isKey(EmbeddedObjArrays,modelH)
            remove(EmbeddedObjArrays,modelH);
            if nargout>0
                varargout{1}=true;
            end
        elseif nargout>0
            varargout{1}=false;
        end

    case 'clearAll'
        totalEntries=EmbeddedObjArrays.Count;
        if totalEntries>0
            delete(EmbeddedObjArrays);
            EmbeddedObjArrays=containers.Map('KeyType','double','ValueType','any');
            if nargout>0
                varargout{1}=totalEntries;
            end
        elseif nargout>0
            varargout{1}=0;
        end

    case 'check'
        varargout{1}=isKey(EmbeddedObjArrays,modelH);

    otherwise
        error(message('Slvnv:rmipref:InvalidArgument',method));
    end
end
