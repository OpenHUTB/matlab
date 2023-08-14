classdef PropertySheet<driving.internal.scenarioApp.PropertySheet

    methods
        function this=PropertySheet(props)
            this@driving.internal.scenarioApp.PropertySheet(props);
        end

        function onInteractiveMode(~)
        end

        function onRoadChanged(~)
        end

        function zValue=getAddRoadCentersZValue(~)
            zValue=[];
        end

        function updateEditPoints(~)

        end
    end
end


