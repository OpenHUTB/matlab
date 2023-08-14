classdef(Abstract)AmiUsage<serdes.internal.ibisami.ami.Keyword





    methods
    end
    methods

        function branch=getKeyWordBranch(usage,~,~)
            branch="(Usage "+usage.Name+")";
        end
    end
end

