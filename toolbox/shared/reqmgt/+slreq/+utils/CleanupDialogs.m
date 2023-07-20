classdef CleanupDialogs


    methods(Static)
        function clearChangeIssues()
            dlgs=findDDGByTag('slreq_clearchange');
            for index=1:length(dlgs)
                try
                    dlgs(index).delete;
                catch ex %#ok<NASGU>

                end
            end

        end
    end
end