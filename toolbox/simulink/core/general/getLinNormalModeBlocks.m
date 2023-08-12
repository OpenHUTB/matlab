function [ normalblks, normalrefs, isloaded ] = getLinNormalModeBlocks( mdl, varargin )







if nargin == 1
loadUnopenedModels = true;
else 
loadUnopenedModels = varargin{ 1 };
end 




[ ~, ~, aGraph ] = find_mdlrefs( mdl, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
analyzer = Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
resultAnyNormal = analyzer.analyze( aGraph, 'AnyNormal', 'IncludeTopModel', false, 'ResultView', 'Instance' );


normalblks = resultAnyNormal.BlockPath( 2:end  );
normalrefs = resultAnyNormal.RefModel( 2:end  );
isloaded = resultAnyNormal.IsLoaded( 2:end  );


resultAnyAccel = analyzer.analyze( aGraph, 'AnyAccel', 'IncludeTopModel', false, 'ResultView', 'Instance' );
anyAccelModels = resultAnyAccel.RefModel;
commonModels = intersect( normalrefs, anyAccelModels, 'stable' );
if ~isempty( commonModels )
DAStudio.error( 'Simulink:tools:linmodNotSupportedMultipleModelReference', commonModels{ 1 } );
end 


if loadUnopenedModels
cellfun( @load_system, normalrefs );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgvBTzy.p.
% Please follow local copyright laws when handling this file.

