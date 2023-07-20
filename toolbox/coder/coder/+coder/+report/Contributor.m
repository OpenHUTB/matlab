


classdef(Abstract)Contributor<coder.internal.gui.Advisable















    properties(Abstract,Constant)
ID
    end

    methods
        function relevant=isRelevant(this,reportContext)%#ok<INUSD>
            relevant=true;
        end

        function supported=isSupportsVirtualMode(this,reportContext)%#ok<INUSD>
            supported=false;
        end

        function riContributor=getRIContributor(this,reportContext)%#ok<INUSD>
            riContributor=[];
        end
    end

    methods(Abstract)
        contribute(this,reportContext,contribContext);
    end

end

