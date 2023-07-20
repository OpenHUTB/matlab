classdef ThreeWayMergeLayout<handle



    properties(Access=private)
        ModelScreenWidthFraction=1/3;
    end


    methods(Access=public,Static)

        function obj=getInstance()
            persistent instance
            if isempty(instance)
                obj=slxmlcomp.internal.highlight.ThreeWayMergeLayout();
                instance=obj;
            else
                obj=instance;
            end
        end

    end


    methods(Access=public)

        function obj=ThreeWayMergeLayout()
            obj=obj@handle();
        end

        function positions=getDefaultPositions(obj,positionID)
            positions=obj.getDefaultWindowPositions(strcmp(positionID,'Top'));
        end

        function position=getReportPosition(obj)
            opts=slxmlcomp.options;
            position=opts.PreferredReportPosition;
            if(isempty(position))
                position=slxmlcomp.internal.highlight.getDefaultReportPosition(...
                1-obj.ModelScreenWidthFraction...
                );
            end
        end

    end


    methods(Access=private)
        function positions=getDefaultWindowPositions(obj,isTop)
            frac=obj.ModelScreenWidthFraction;
            positions=struct('Simulink',slxmlcomp.internal.highlight.getDefaultSystemPosition(isTop,frac),...
            'Stateflow',slxmlcomp.internal.highlight.getDefaultChartPosition(isTop,frac),...
            'TruthTable',slxmlcomp.internal.truthTable.getDefaultUIPosition(isTop,frac));
        end
    end

end

