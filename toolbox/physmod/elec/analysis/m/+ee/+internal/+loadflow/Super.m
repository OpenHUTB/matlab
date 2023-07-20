classdef Super<handle





    properties(Abstract)
Name
    end

    properties(Access=protected)

        FindArgs=ee.internal.loadflow.Super.findSysArgs();
    end

    methods(Static)
        function args=findSysArgs()
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                args={...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'BlockType','SimscapeBlock'};
            else
                args={...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'Variants','ActiveVariants',...
                'BlockType','SimscapeBlock'};
            end
        end
    end
end
