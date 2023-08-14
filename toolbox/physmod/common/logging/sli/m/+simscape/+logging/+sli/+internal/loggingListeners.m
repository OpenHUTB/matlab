function result=loggingListeners(modelName,loggingListener)




    persistent pListeners;

    if isempty(pListeners)
        pListeners=containers.Map;
    end

    if nargin==1
        if pListeners.isKey(modelName)
            result=pListeners(modelName);
        else
            result=[];
        end
    elseif nargin==2
        if~isempty(loggingListener)
            pListeners(modelName)=loggingListener;
        else
            if pListeners.isKey(modelName)
                pListeners.remove(modelName);
            end
        end
        result=pListeners.keys;
    else
        result=pListeners.keys;
    end
end
