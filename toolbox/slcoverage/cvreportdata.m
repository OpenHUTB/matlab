function varargout=cvreportdata(modelName,varargin)








    persistent modelToCvDataMap;

    try
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
        if status==0
            error(message(msgId));
        end
        if~ischar(modelName)
            modelName=get_param(modelName,'Name');
        end

        if~isempty(varargin)
            if isempty(modelToCvDataMap)
                modelToCvDataMap=containers.Map('KeyType','char','ValueType','any');
            end
            cvd=varargin{1};

            if isempty(cvd)
                if modelToCvDataMap.isKey(modelName)
                    modelToCvDataMap.remove(modelName);
                end
            else
                if~valid(cvd)

                    return;
                end

                modelToCvDataMap(modelName)=cvd;
            end
        else
            varargout{1}=[];
            if~isempty(modelToCvDataMap)
                if modelToCvDataMap.isKey(modelName)
                    cvd=modelToCvDataMap(modelName);
                    if valid(cvd)
                        varargout{1}=cvd;
                    end
                end
            end
        end

    catch MEx
        rethrow(MEx);
    end

