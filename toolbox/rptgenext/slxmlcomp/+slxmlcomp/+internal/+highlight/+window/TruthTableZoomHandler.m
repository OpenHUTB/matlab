classdef TruthTableZoomHandler<slxmlcomp.internal.highlight.window.SLEditorZoomHandler




    properties(Access=private)
        SupportedTypes=["StateflowTruthTable","SimulinkTruthTable","ConditionTable"];

    end

    methods(Access=public)

        function canHandle=canHandle(obj,location)
            canHandle=any(obj.SupportedTypes==location.Type);
        end

        function zoomTo(~,location)
            switch location.Type
            case{"StateflowTruthTable"}
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location.Location);
                truthTable=slxmlcomp.internal.stateflow.chart.get(...
                stateflowInfo.Block,...
                'Stateflow.TruthTable',...
                stateflowInfo.SSID...
                );

            case{"ConditionTable","SimulinkTruthTable"}
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location.Location);
                truthTable=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.TruthTable');

            otherwise
                error('Unknown truthtable type');
            end

            truthTable.view;
        end

    end

end
