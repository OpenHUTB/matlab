classdef AnalysisGroup < matlab.ui.internal.FigureDocumentGroup

    properties
        Analysis
    end

    methods

        function obj = AnalysisGroup( Analysis )

            arguments
                Analysis( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Analysis = rfpcb.internal.apps.transmissionLineDesigner.model.Analysis;
            end
            obj.Analysis = Analysis;
            obj.Tag = 'analysisGroup';

            debug( obj.Analysis.Logger, 'AnalysisGroup = matlab.ui.internal.FigureDocumentGroup("Tag", "analysisGroup");' );
        end
    end
end

