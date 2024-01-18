function varargout=storageModeCache(method,modelH,value)

    persistent rmiStorageModes transientModes
    mlock;
    if isempty(rmiStorageModes)
        rmiStorageModes=containers.Map('KeyType','double','ValueType','logical');
        transientModes=containers.Map('KeyType','double','ValueType','logical');
    end

    if nargin>1&&ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end

    switch method
    case 'get'
        if~isKey(rmiStorageModes,modelH)

            if isempty(get_param(modelH,'FileName'))
                varargout{1}=false;
                return;
            else
                rmidata.init(modelH);
            end
        end
        varargout{1}=rmiStorageModes(modelH);

    case 'set'

        rmiStorageModes(modelH)=value;

    case 'remove'
        if isKey(rmiStorageModes,modelH)
            remove(rmiStorageModes,modelH);
            if nargout>0
                varargout{1}=true;
            end
        elseif nargout>0
            varargout{1}=false;
        end

        if nargin<3||value
            rmidata.duplicateDisabled(get_param(modelH,'Name'));

            if isKey(transientModes,modelH)
                remove(transientModes,modelH);
            end
        end

    case 'clearAll'
        totalEntries=rmiStorageModes.Count;
        if totalEntries>0
            delete(rmiStorageModes);
            rmiStorageModes=containers.Map('KeyType','double','ValueType','logical');
            if nargout>0
                varargout{1}=totalEntries;
            end
        elseif nargout>0
            varargout{1}=0;
        end

    case 'check'
        varargout{1}=isKey(rmiStorageModes,modelH);

    case 'mark_from_lib'
        transientModes(modelH)=true;

    case 'marked_from_lib'
        varargout{1}=isKey(transientModes,modelH);

    otherwise
        error(message('Slvnv:rmipref:InvalidArgument',method));
    end

end
