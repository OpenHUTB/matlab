classdef TwoSourceWindowLayout<handle





    properties(Access=private)
        ModelScreenWidthFraction=0.5;
    end


    methods(Access=public,Static)

        function obj=getInstance()
            persistent instance
            if isempty(instance)
                obj=slxmlcomp.internal.highlight.TwoSourceWindowLayout();
                instance=obj;
            else
                obj=instance;
            end
        end
    end


    methods(Access=public)

        function obj=TwoSourceWindowLayout()
            obj=obj@handle;
        end

        function position=getReportPosition(obj)
            opts=slxmlcomp.options;
            position=opts.PreferredReportPosition;
            if isempty(position)
                position=slxmlcomp.internal.highlight.getDefaultReportPosition(...
                1-obj.ModelScreenWidthFraction...
                );
            end
        end

        function positions=getDefaultPositions(obj,positionID)
            positions.Simulink=obj.getInitialSimulinkPosition(positionID);
            positions.Stateflow=obj.getInitialStateflowPosition(positionID);
        end

    end


    methods(Access=private)

        function simulinkPosition=getInitialSimulinkPosition(obj,side)
            opts=slxmlcomp.options;
            simulinkPosition=opts.(['PreferredSimulinkPosition',side]);
            if isempty(simulinkPosition)
                isTop=strcmp(side,'Left');
                simulinkPosition=slxmlcomp.internal.highlight.getDefaultSystemPosition(...
                isTop,obj.ModelScreenWidthFraction...
                );
            end
        end

        function stateflowPosition=getInitialStateflowPosition(obj,side)
            opts=slxmlcomp.options;
            stateflowPosition=opts.(['PreferredStateflowPosition',side]);
            if isempty(stateflowPosition)
                isTop=strcmp(side,'Left');
                stateflowPosition=slxmlcomp.internal.highlight.getDefaultChartPosition(...
                isTop,obj.ModelScreenWidthFraction...
                );
            end
        end

    end

end
