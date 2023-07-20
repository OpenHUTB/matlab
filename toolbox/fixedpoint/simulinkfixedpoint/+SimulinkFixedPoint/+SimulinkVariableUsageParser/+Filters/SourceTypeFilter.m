classdef(Abstract)SourceTypeFilter<handle







    properties(SetAccess=protected)
        InvalidValues;
    end

    methods
        function this=SourceTypeFilter()
            registerInvalidValues(this);
        end
        function validUsages=getValidUsages(this,usages)



            validUsageIndex=true(numel(usages),1);
            for iUsage=1:numel(usages)
                source=getSourceType(usages(iUsage));
                validUsageIndex(iUsage)=~any(contains(source,this.InvalidValues));
            end
            validUsages=usages(validUsageIndex);
        end
    end
    methods(Access=protected)
        registerInvalidValues(this);
    end
end


