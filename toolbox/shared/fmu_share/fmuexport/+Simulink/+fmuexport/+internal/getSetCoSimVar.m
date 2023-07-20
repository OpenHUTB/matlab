
function varargout=getSetCoSimVar(modelName,varName,varargin)




mlock
    persistent varMap

    if~isa(varMap,'containers.Map')
        varMap=containers.Map('KeyType','char','ValueType','any');
    end

    if isempty(varName)

        idxToRemove=startsWith(varMap.keys,[modelName,'.']);
        keys=varMap.keys;
        varMap.remove(keys(idxToRemove));
        return
    end

    entry=[modelName,'.',varName];

    if nargout
        if varMap.isKey(entry)
            varargout{1}=varMap(entry);
        else
            varargout{1}=[];
        end
    end

    if~isempty(varargin)

        varMap(entry)=varargin{1};
    end
end

