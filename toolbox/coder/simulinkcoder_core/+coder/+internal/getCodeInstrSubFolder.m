function [ lCodeInstrObjFolder, lCodeInstrSrcFolder ] ...
 = getCodeInstrSubFolder( lTopModel, lIsSilAndPws, lModelReference, isSil )




R36
lTopModel
lIsSilAndPws
lModelReference = ''
isSil = true
end 

if isempty( lModelReference )


lModelReference = lTopModel;
end 


lBuildHooks = coder.coverage.getBuildHooks( lTopModel );


codeCovSettings = slprivate( 'getCodeCoverageSettings', lTopModel );
if strcmp( codeCovSettings.CoverageTool, SlCov.getCoverageToolName(  ) )
lBuildHooks = coder.coverage.updateBuildHooks( codeCovSettings, lBuildHooks );
end 


lCodeCoverageSettings = coder.coverage.CodeCoverageSettings( lBuildHooks );
lCodeCoverageSpec = [  ];
if ~strcmp( lCodeCoverageSettings.CoverageTool, 'None' )
lCodeCoverageSpec = coder.internal.CodeInstrSpecCoverageSL ...
( lCodeCoverageSettings, lTopModel, isSil );
end 


lCodeExecutionTimeProfilingTop = strcmp ...
( get_param( lTopModel, 'CodeExecutionProfiling' ), 'on' );

lCodeExecutionStackProfilingTop = strcmp ...
( get_param( lTopModel, 'CodeStackProfiling' ), 'on' );


modelRefsAll = {  };
protectedModelRefs = {  };

if lCodeExecutionStackProfilingTop
modelsWithProfiling = unique( { lTopModel, lModelReference } );
else 
models = unique( { lTopModel, lModelReference } );
idx = ~strcmp( get_param( models, 'CodeProfilingInstrumentation' ), 'off' );
modelsWithProfiling = models( idx );
end 

lCodeInstrInfo = coder.internal.slCreateCodeInstrBuildArgs ...
( lModelReference,  ...
lIsSilAndPws,  ...
lCodeCoverageSpec,  ...
lCodeExecutionTimeProfilingTop || lCodeExecutionStackProfilingTop,  ...
modelsWithProfiling,  ...
modelRefsAll,  ...
protectedModelRefs );

lCodeInstrObjFolder = '';
lCodeInstrSrcFolder = '';

if ~isempty( lCodeInstrInfo )
lCodeInstrObjFolder = lCodeInstrInfo.getInstrObjFolder;
lCodeInstrSrcFolder = lCodeInstrInfo.getInstrSrcFolder;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjAtR5F.p.
% Please follow local copyright laws when handling this file.

