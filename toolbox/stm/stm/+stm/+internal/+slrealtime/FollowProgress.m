classdef FollowProgress

    methods(Static)


        function out=verboseLevel(in)
            persistent v;
            if nargin
                v=in;
            end
            out=v;
        end

        function progress(msg)
            if stm.internal.slrealtime.FollowProgress.verboseLevel
                fprintf('%s\n',msg);
            end
        end
    end

end

