function result=getExclusion(modelName,varargin)






























    try
        result=[];
        validStr=@(x)~isempty(x)&&ischar(x)||isstring(x);
        validType=@(x)any(validatestring(x,slcheck.getExpectedFilterTypes));

        p=inputParser;
        addRequired(p,'modelName',validStr);
        addOptional(p,'type','',validType);
        addOptional(p,'id','',validStr);
        addParameter(p,'check','',@ischar);
        parse(p,modelName,varargin{:});

        manager=slcheck.getAdvisorFilterManager(p.Results.modelName);

        if~isempty(p.Results.type)&&~isempty(p.Results.id)&&~isempty(p.Results.check)
            result=manager.getAdvisorFilterSpecification(...
            slcheck.getFilterTypeEnum(p.Results.type),...
            slcheck.getsid(p.Results.id),p.Results.check);
        elseif~isempty(p.Results.type)&&~isempty(p.Results.id)
            result=manager.getFilterSpecification(...
            slcheck.getFilterTypeEnum(p.Results.type),...
            slcheck.getsid(p.Results.id));
        else
            result=manager.filters;
        end
    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_get'),ex.message]);
    end

end

