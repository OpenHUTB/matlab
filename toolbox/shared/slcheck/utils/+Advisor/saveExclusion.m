function saveExclusion(modelName,varargin)


























    try
        validStr=@(x)ischar(x)||isstring(x);

        p=inputParser;
        addRequired(p,'modelName',validStr);
        addParameter(p,'filePath',slcheck.getFilterFilePath(modelName),validStr);

        parse(p,modelName,varargin{:});

        manager=slcheck.getAdvisorFilterManager(p.Results.modelName);

        if nargin==1
            filePath=which(p.Results.filePath);
            if isempty(filePath)
                filePath=p.Results.filePath;
            end
            manager.saveToFile(filePath);
            slcheck.refreshEdittimeExclusions(p.Results.modelName);
            return;
        end

        if strcmp(p.Results.filePath,'')
            set_param(p.Results.modelName,'MAModelFilterFile','');
            manager.saveToFile(slcheck.getFilterFilePath(p.Results.modelName));
        elseif~isempty(p.Results.filePath)
            filePath=which(p.Results.filePath);
            if isempty(filePath)
                filePath=p.Results.filePath;
            end
            set_param(p.Results.modelName,'MAModelFilterFile',filePath);
            manager.saveToFile(filePath);
        end

        slcheck.refreshEdittimeExclusions(p.Results.modelName);

    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_save'),ex.message]);
    end

end

