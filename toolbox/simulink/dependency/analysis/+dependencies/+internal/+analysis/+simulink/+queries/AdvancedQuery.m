classdef(Abstract)AdvancedQuery




    methods(Abstract)
        [loadSaveQuery,numMatches]=createLoadSaveQueries(this)
        match=createMatch(this,handler,node,matches);
    end

end
