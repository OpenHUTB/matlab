function precompile = usePrecompiledLibraries( modelName )








R36
modelName = bdroot;
end 

modelName = get_param( modelName, 'Name' );

modelCodegenMgr = coder.internal.ModelCodegenMgr.getInstance( modelName );

templateMakefile = get_param( modelName, 'TemplateMakefile' );





isSLDRT = ~isempty( regexp( templateMakefile, 'sldrt\w*\.tmf$', 'once' ) ) ||  ...
~isempty( regexp( templateMakefile, 'rtwin\w*\.tmf$', 'once' ) );


isSlRealTime = strcmp( get_param( modelName, 'SystemTargetFile' ), 'slrealtime.tlc' );



precompile = modelCodegenMgr.CompilerSupportsBuildingMEXFuncs || isSLDRT || isSlRealTime;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTsiGJS.p.
% Please follow local copyright laws when handling this file.

