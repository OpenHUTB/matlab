classdef AnalysisGroup < matlab.ui.internal.FigureDocumentGroup




properties 
Analysis
end 

methods 

function obj = AnalysisGroup( Analysis )

R36
Analysis( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Analysis = rfpcb.internal.apps.transmissionLineDesigner.model.Analysis;
end 
obj.Analysis = Analysis;
obj.Tag = 'analysisGroup';

debug( obj.Analysis.Logger, 'AnalysisGroup = matlab.ui.internal.FigureDocumentGroup("Tag", "analysisGroup");' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpOp5GeH.p.
% Please follow local copyright laws when handling this file.

