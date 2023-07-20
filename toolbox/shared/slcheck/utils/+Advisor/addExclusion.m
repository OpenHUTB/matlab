function addExclusion(modelName,type,id,varargin)







































    persistent value;
    try
        if(isempty(value))
            value=true;
            Simulink.DDUX.logData('EXCLUSION','maexclusioncli',value);
        end

        defaultCheck='.*';
        validArray=@(x)ischar(x)||iscell(x);
        validStr=@(x)~isempty(x)&&ischar(x)||isstring(x);

        p=inputParser;
        addRequired(p,'modelName',validStr);
        addRequired(p,'type',@(x)any(validatestring(x,slcheck.getExpectedFilterTypes)));
        addRequired(p,'id',validArray);
        addParameter(p,'rationale','',validStr);
        addParameter(p,'checks',defaultCheck,validArray);
        addParameter(p,'validateChecks',false,@islogical);
        parse(p,modelName,type,id,varargin{:});

        if~iscell(p.Results.checks)
            checks={p.Results.checks};
        else
            checks=p.Results.checks;
        end

        if p.Results.validateChecks&&~strcmp(checks{1},defaultCheck)
            result=cellfun(@(x)slcheck.doesCheckSupportExclusion(modelName,x),checks);
            queryResult=checks(~result);
            if~isempty(queryResult)
                disp(DAStudio.message('slcheck:filtercatalog:CheckDoesNotSupportExclusion'));
                disp(queryResult);
            end
            checks=checks(result);
        end

        manager=slcheck.getAdvisorFilterManager(p.Results.modelName);

        enumType=slcheck.getFilterTypeEnum(p.Results.type);
        if ischar(p.Results.id)
            manager.addAdvisorFilterSpecificationArray(...
            slcheck.getsid(p.Results.id),...
            enumType,...
            advisor.filter.FilterMode.Exclude,...
            p.Results.rationale,checks);
        else
            for idx=1:numel(p.Results.id)
                manager.addAdvisorFilterSpecificationArray(...
                slcheck.getsid(p.Results.id{idx}),...
                enumType,...
                advisor.filter.FilterMode.Exclude,...
                p.Results.rationale,checks);
            end
        end


        slcheck.refreshExclusionUI(modelName);
    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_add'),ex.message]);
    end
end


