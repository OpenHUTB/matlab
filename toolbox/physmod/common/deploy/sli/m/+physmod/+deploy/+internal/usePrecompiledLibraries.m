function precompile = usePrecompiledLibraries( modelName )

arguments
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


