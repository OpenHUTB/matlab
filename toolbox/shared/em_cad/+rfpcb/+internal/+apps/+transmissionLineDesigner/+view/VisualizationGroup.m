classdef VisualizationGroup < matlab.ui.internal.FigureDocumentGroup

    properties
        Visualization
    end

    methods

        function obj = VisualizationGroup( Visualization )

            arguments
                Visualization( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Visualization = rfpcb.internal.apps.transmissionLineDesigner.model.Visualization;
            end
            obj.Visualization = Visualization;
            obj.Tag = 'visualizationGroup';

            debug( obj.Visualization.Logger, 'VisualizationGroup = matlab.ui.internal.FigureDocumentGroup("Tag", "visualizationGroup");' );
        end
    end
end


