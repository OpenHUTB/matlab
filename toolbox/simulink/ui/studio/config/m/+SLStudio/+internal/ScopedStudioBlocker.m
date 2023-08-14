classdef ScopedStudioBlocker<handle
    properties(Access=private,Hidden)
        ScopedStudioBlockerInternal;
    end

    methods
        function self=ScopedStudioBlocker(msg)
            if nargin==1
                self.ScopedStudioBlockerInternal=SLM3I.ScopedStudioBlocker(msg);
            else
                self.ScopedStudioBlockerInternal=SLM3I.ScopedStudioBlocker;
            end
        end

        function delete(self)
            delete(self.ScopedStudioBlockerInternal);
        end
    end
end