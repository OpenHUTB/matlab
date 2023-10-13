classdef ClassDiagramCleanUpRules < classdiagram.app.core.notifications.CleanUpRules

    methods
        function obj = ClassDiagramCleanUpRules( options )
            arguments
                options.keep( 1, : )string;
                options.remove( 1, : )string;
                options.conditions( 1, : );
            end
            obj = obj@classdiagram.app.core.notifications.CleanUpRules(  ...
                keep = options.keep,  ...
                conditions = options.conditions );
        end

        function [ keep, remove ] = applyRules( obj, option )
            if isfield( option, 'current' ) && ~isempty( option.current )
                [ keep, remove ] = obj.matchRules( option.current );
            else
                [ keep, remove ] = applyRules@classdiagram.app.core.notifications.CleanUpRules( obj, option );
            end
        end
    end

    methods ( Access = private )
        function [ keep, remove ] = matchRules( obj, current )

            idx = contains( [ current.Category ], obj.conditions.condition );
            if ismember( 1, idx )
                rule = obj.conditions;
            else
                rule = [  ];
            end
            if isempty( rule )
                keep = obj.keep;
                remove = obj.remove;
            else
                keep = rule.keep;
                remove = rule.remove;
            end
        end
    end
end


