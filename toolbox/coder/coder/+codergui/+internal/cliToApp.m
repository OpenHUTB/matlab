

function varargout = cliToApp( activity, projectFile, varargin )

error( javachk( 'jvm' ) );
activity = validatestring( activity, {
    'codegen2project'
    'cli2project'
    'config2project'
    'project2project'
    'project2codegen'
    'project2config'
    } );

projectFile = normalizeProjectFileArg( projectFile );

if activity == "project2project"
    narginchk( 3, intmax );
    varargout = handleProjectToProject( projectFile, varargin{ : } );
elseif endsWith( activity, '2project' )
    narginchk( 3, intmax );
    mode = validatestring( varargin{ 1 }, { 'create', 'import' } );
    varargin = varargin( 2:end  );
    checkTargetFileStatus( projectFile, true, mode ~= "create" );
    varargout = handleImporterActivities( activity, mode, projectFile, varargin{ : } );
elseif activity == "emptyproject"
    checkTargetFileStatus( projectFile, true, false );
    parameters = varargin( 1:2:end  );
    if ~all( ismember( parameters, { 'UseEmbeddedCoder', 'BuildType' } ) )
        error( 'Only UseEmbeddedCoder and BuildType are supported when generating empty projects' );
    end
    varargout = handleImporterActivities( activity, 'create', projectFile, varargin{ : } );
else
    narginchk( 2, intmax );
    if ~isfile( projectFile )
        doError( 'Coder:common:CliToAppProjectFileNotFound', projectFile );
    end
    varargout = handleProjectToCodegen( activity, projectFile, varargin{ : } );
end
end


function outputs = handleImporterActivities( activity, mode, projectFile, varargin )
javaImporter = [  ];
completionHandler = [  ];
timeoutHandler = [  ];
cleanupHandles = {  };
failedValues = cell( 0, 2 );

if mode == "create"
    successKey = 'Coder:common:CliToAppProjectCreated';
    errorKey = 'Coder:common:CliToAppProjectCreationFailure';
else
    successKey = 'Coder:common:CliToAppImportSuccessful';
    errorKey = 'Coder:common:CliToAppProjectImportFailure';
end

switch activity
    case "codegen2project"
        narginchk( 4, intmax );
        configureForCodegenPath( varargin{ : } );
    case "config2project"
        narginchk( 4, intmax );
        configureForConfigPath( varargin{ : } );
    otherwise
        narginchk( 3, intmax );
        configureForGenericPath( varargin{ : } );
end

assert( ~isempty( javaImporter ) && ~isempty( completionHandler ) && ~isempty( timeoutHandler ),  ...
    'Definition of "%s" handler is incomplete', activity );

cleanupHandles{ end  + 1 } = onCleanup( @javaImporter.cancel );
if mode == "create"
    folder = fileparts( projectFile );
    if ~isfolder( folder )
        mkdir( folder );
    end
    javaImporter.createNew( java.io.File( projectFile ) );
else
    javaImporter.importInto( java.io.File( projectFile ) );
end
pollSuccess = codergui.internal.util.poll( @javaImporter.isDone, 'Timeout', 60 );

if pollSuccess
    if ~isempty( failedValues )
        warnOfFailedValueEmbed( failedValues );
    end
    outputs = completionHandler(  );
else
    timeoutHandler(  );
end


    function configureForCodegenPath( coderContext, varargin )
        validateattributes( coderContext, { 'coder.internal.CompilationContext' }, { 'scalar' } );
        if ~coderContext.isCodeGenClient(  ) || isa( coderContext.ConfigInfo, 'coder.HdlConfig' )
            doError( 'Coder:common:CliToAppNotEmlc' );
        elseif ~isempty( coderContext.JavaConfig )
            doError( 'Coder:common:CliToAppJavaProject' );
        end

        persistent ip;
        if isempty( ip )
            ip = createInputParser(  );
            ip.addParameter( 'UserLogDir', '', @( v )emptyOrValidate( v, { 'char', 'string' }, { 'scalartext' } ) );
            ip.addParameter( 'UserCodeTemplate', [  ], @( v )emptyOrValidate( v, { 'coder.CodeTemplate' }, { 'scalar' } ) );
            ip.addParameter( 'Overwrite', false, @islogical );
        end
        ip.parse( varargin{ : } );
        opts = ip.Results;
        if isstring( opts.UserLogDir )
            opts.UserLogDir = char( opts.UserLogDir );
        end

        javaImporter = com.mathworks.toolbox.coder.app.CodegenToProjectImporter(  );

        if isempty( coderContext.FixptData ) && isa( coderContext.ConfigInfo, 'coder.FixPtConfig' )

            coderConfig = [  ];
            fixptConfig = coderContext.ConfigInfo;
            javaImporter.setAppOverride( 'fixed_point' );
        else

            coderConfig = coderContext.ConfigInfo;
            fixptConfig = coderContext.FixptData;
        end
        if ~isempty( coderConfig ) && isprop( coderConfig, 'F2FConfig' ) && ~isempty( coderConfig.F2FConfig ) &&  ...
                coderConfig.F2FConfig.DoubleToSingle
            javaImporter.setSinglesConversionEnabled( true );
        end

        [ cleanupHandles, failedValues ] = configureImporter( javaImporter,  ...
            CoderConfig = coderConfig,  ...
            FloatToFixedConfig = fixptConfig,  ...
            EntryPoints = coderContext.Project.EntryPoints,  ...
            Globals = coderContext.Project.InitialGlobalValues,  ...
            TestFile = coderContext.CommandArgs.runTestFile,  ...
            UserLogDir = opts.UserLogDir,  ...
            UserCodeTemplate = opts.UserCodeTemplate,  ...
            OutputName = coderContext.Project.FileName,  ...
            FeatureControl = coderContext.Project.FeatureControl );

        completionHandler = @onSuccess;
        timeoutHandler = @(  )doError( errorKey, projectFile );


        function output = onSuccess(  )
            import matlab.internal.lang.capability.Capability;
            if ~opts.Silent
                if Capability.isSupported( Capability.ComplexSwing )
                    linkText = [ newline(  ), message( 'Coder:common:CliToAppProjectCreatedLink', projectFile ).getString(  ) ];
                else
                    linkText = '';
                end
                fprintf( '\n%s%s\n\n', message( successKey, getFilename( projectFile ) ).getString(  ), linkText );
            end
            output = {  };
        end
    end


    function configureForConfigPath( config, varargin )
        validateattributes( config, { 'coder.Config', 'coder.ReportInfo' }, { 'scalar' } );
        if isa( config, 'coder.ReportInfo' )
            config = config.Config;
        end
        configureForGenericPath( 'CoderConfig', config, varargin{ : } );
    end


    function configureForGenericPath( varargin )
        persistent ip;
        if isempty( ip )
            ip = createInputParser(  );
            ip.addParameter( 'CoderConfig', [  ], @( v )emptyOrValidate( v, { 'coder.Config' }, { 'scalar' } ) );
            ip.addParameter( 'FloatToFixedConfig', [  ], @( v )emptyOrValidate( v, { 'coder.FixPtConfig' }, { 'scalar' } ) );
            ip.addParameter( 'EntryPoints', [  ], @( v )emptyOrValidate( v, { 'coder.internal.EntryPoint' }, { 'vector' } ) );
            ip.addParameter( 'Globals', [  ], @( v )emptyOrValidate( v, { 'cell' }, { '2d' } ) );
            ip.addParameter( 'UserLogDir', '', @( v )emptyOrValidate( v, { 'char', 'string' }, { 'scalartext' } ) );
            ip.addParameter( 'UserCodeTemplate', '', @( v )emptyOrValidate( v, { 'coder.CodeTemplate' }, { 'scalar' } ) );
            ip.addParameter( 'OutputName', '', @( v )emptyOrValidate( v, { 'char', 'string' }, { 'scalartext' } ) );
            ip.addParameter( 'TestFile', '', @( v )emptyOrValidate( v, { 'char', 'string' }, { 'scalartext' } ) );
            ip.addParameter( 'FeatureControl', [  ], @( v )emptyOrValidate( v, { 'coder.internal.FeatureControl' }, { 'scalar' } ) );
            ip.addParameter( 'AppOverride', '', @( v )isempty( v ) || any( strcmpi( v, { 'c', 'gpu', 'fixed_point' } ) ) );
            ip.addParameter( 'UseEmbeddedCoder', [  ], @( v )isempty( v ) || islogical( v ) );
            ip.addParameter( 'BuildType', [  ], @( v )isempty( v ) || any( strcmpi( v, { 'lib', 'dll', 'mex' } ) ) );
        end

        ip.parse( varargin{ : } );
        opts = ip.Results;
        if isstring( opts.UserLogDir )
            opts.UserLogDir = char( opts.UserLogDir );
        end
        if ~isempty( opts.AppOverride )
            opts.AppOverride = com.mathworks.toolbox.coder.app.GenericArtifact.valueOf( upper( opts.AppOverride ) );
        end

        javaImporter = com.mathworks.toolbox.coder.app.CodegenToProjectImporter(  );
        namedArgs = namedargs2cell( rmfield( opts, { 'Silent', 'AppOverride' } ) );
        [ cleanupHandles, failedValues ] = configureImporter( javaImporter, namedArgs{ : } );
        if ~isempty( opts.AppOverride )
            javaImporter.setAppOverride( opts.AppOverride );
        end

        completionHandler = @onSuccess;
        timeoutHandler = @(  )doError( errorKey, projectFile );


        function output = onSuccess(  )
            if ~opts.Silent
                disp( message( successKey, projectFile ).getString(  ) );
            end
            output = {  };
        end
    end
end


function [ cleanupHandles, failedValues ] = configureImporter( javaImporter, opts )
arguments
    javaImporter
    opts.CoderConfig = [  ]
    opts.FloatToFixedConfig = [  ]
    opts.EntryPoints = [  ]
    opts.Globals = [  ]
    opts.TestFile = ''
    opts.UserLogDir = ''
    opts.UserCodeTemplate = [  ]
    opts.OutputName = ''
    opts.FeatureControl = [  ]
    opts.UseEmbeddedCoder = [  ]
    opts.BuildType = [  ]
end

failedInputs = cell( 0, 2 );
if ~isempty( opts.EntryPoints )
    entryPoints = validateEntryPoints( opts.EntryPoints );
    if ~isempty( entryPoints )
        [ itXmls, failedInputs ] = convertEntryPointTypesToXml( entryPoints );
        for i = 1:numel( entryPoints )
            ep = entryPoints( i );
            javaImporter.addEntryPoint( ep.Name, getAbsolutePath( ep ), itXmls{ i } );
        end
    end
end

if ~isempty( opts.Globals )
    [ globalsXml, failedGlobals ] = convertGlobalTypesToXml( opts.Globals );
    javaImporter.setGlobalsXml( globalsXml );
else
    failedGlobals = cell( 0, 2 );
end

if ~isempty( opts.UserLogDir )
    javaImporter.setBuildFolder( opts.UserLogDir );
end

if ~isempty( opts.OutputName )
    javaImporter.setOutputName( opts.OutputName );
end

if ~isempty( opts.TestFile )
    try
        testFile = which( opts.TestFile );
        if ~isempty( testFile )
            javaImporter.setTestFile( testFile );
        end
    catch
    end
end



cleanupHandles = {  };
if ~isempty( opts.CoderConfig )
    [ cfgVar, cleanupHandles{ end  + 1 } ] = reserveWorkspaceVariable( opts.CoderConfig );
    javaImporter.setConfigVariable( cfgVar );

    if ~isempty( opts.UserCodeTemplate )
        emlcprivate( 'ccwarningid', 'Coder:common:CliToAppCgtUnsupported' );
    end
end
if ~isempty( opts.FloatToFixedConfig )
    [ cfgVar, cleanupHandles{ end  + 1 } ] = reserveWorkspaceVariable( opts.FloatToFixedConfig );
    javaImporter.setFixedPointConfigVariable( cfgVar );
end

if ~isempty( opts.FeatureControl )
    javaImporter.setFeatureFlags( codergui.internal.featureControlToExpression( opts.FeatureControl ) );
end

if ~isempty( opts.UseEmbeddedCoder )
    javaImporter.setUseEmbeddedCoder( opts.UseEmbeddedCoder );
end
if ~isempty( opts.BuildType )
    javaImporter.setBuildType( opts.BuildType );
end

failedValues = [ failedInputs;failedGlobals ];
end


function [ xmls, failed ] = convertEntryPointTypesToXml( eps )
failed = cell( 0, 2 );
xmls = arrayfun( @convertEntryPointTypes, eps, 'UniformOutput', false );


    function xml = convertEntryPointTypes( ep )
        xmlBuilder = codergui.internal.TypeRootXmlBuilder( 'inputTypes', @onConstantValueFailure );
        xmlBuilder.FunctionName = ep.Name;
        xmlBuilder.File = getAbsolutePath( ep );
        xmlBuilder.Types = ep.InputTypes;
        xmlBuilder.HasInputTypes = ep.HasInputTypes;

        if ep.HasUserNumOutputs
            xmlBuilder.NumOutputs = ep.UserNumOutputs;
        end

        xml = xmlBuilder.toXml(  );


        function onConstantValueFailure( ~, ~, name, ~ )
            failed( end  + 1, : ) = { ep, name };
        end
    end
end


function [ globalsXml, failed ] = convertGlobalTypesToXml( globalTypes )
failed = cell( 0, 2 );
xmlBuilder = codergui.internal.TypeRootXmlBuilder( 'globals', @onGlobalValueFailure );
xmlBuilder.GlobalNames = cellfun( @( it )it.Name, globalTypes, 'UniformOutput', false );
xmlBuilder.Types = globalTypes;
globalsXml = xmlBuilder.toXml(  );


    function onGlobalValueFailure( ~, ~, name, ~ )
        failed{ end  + 1, 2 } = name;
    end
end


function output = handleProjectToCodegen( activity, projectFile )
success = true;
if ~isOpenAppProject( projectFile )




    try
        appProject = com.mathworks.project.impl.model.ProjectManager.load( java.io.File( projectFile ), true, false );
        projectCloser = onCleanup( @(  )com.mathworks.project.impl.model.ProjectManager.close( appProject, true ) );
    catch
        appProject = [  ];
        success = false;
    end
else
    appProject = getOpenAppProject(  );
end

if ~success || isempty( appProject ) || isa( appProject, 'java.lang.Exception' )
    doError( 'Coder:common:CliToAppExportGenericFailure', projectFile );
    assert( false, 'Statement should be unreachable' );
end

javaConfig = appProject.getConfiguration(  );
if activity == "project2config"
    output{ 1 } = javaConfigToConfig( javaConfig );
else
    result = emlcprivate( 'emlckernel', 'codegen', '--javaConfig', javaConfig, projectFile, '--parseOnly' );
    if isfield( result, 'internal' )
        doError( 'Coder:common:CliToAppExportGenericFailure', projectFile );
    else
        output{ 1 } = result.compilationContext;
    end
end
end


function cfg = javaConfigToConfig( javaConfig )
if com.mathworks.toolbox.coder.app.UnifiedTargetFactory.OLD_HDL_TARGET_KEY.equals( javaConfig.getTargetKey(  ) )
    doError( 'Coder:common:CliToAppExportHdlCoderUnsupported' );
end
isEcoder = com.mathworks.toolbox.coder.plugin.Utilities.isUseECoder( javaConfig );
artifactValue = char( javaConfig.getParamAsString( com.mathworks.toolbox.coder.plugin.Utilities.PARAM_ARTIFACT_TAG ) );
artifactValue = lower( extractAfter( artifactValue, find( artifactValue == '.', 1, 'last' ) ) );
switch char( name( com.mathworks.toolbox.coder.app.GenericArtifact.fromConfiguration( javaConfig ) ) )
    case 'C'
        cfg = coder.config( artifactValue, 'ECODER', isEcoder );
    case 'GPU'
        cfg = coder.gpuConfig( artifactValue, 'ECODER', isEcoder );
    case 'FIXED_POINT'
        cfg = codergui.evalprivate( 'syncFixPtConfigWithJava', 'tocfg', [  ], javaConfig );
        return
    otherwise
        doError( 'Coder:common:CliToAppExportUnsupportedProject', char( javaConfig.getProject(  ).getFile(  ).getPath(  ) ) );
end
emlcprivate( 'copyProjectToConfigObject', javaConfig.getProject(  ), cfg, true );
end


function [ varName, cleanup ] = reserveWorkspaceVariable( value )
if nargin == 0
    value = [  ];
end

baseVarNames = evalin( 'base', 'who' );
varName = '';
num = 1;
while isempty( varName ) || ismember( varName, baseVarNames )
    varName = sprintf( 'cliToAppTempVar%d', num );
    num = num + 1;
end

cleanup = onCleanup( @(  )evalin( 'base', sprintf( 'clear %s', varName ) ) );
assignin( 'base', varName, value );
end


function result = handleProjectToProject( srcProject, destProject, varargin )
checkTargetFileStatus( srcProject, false, true );
destProject = normalizeProjectFileArg( destProject );
createMode = ~isfile( destProject );

persistent ip;
if isempty( ip )
    ip = createInputParser(  );
    ip.addParameter( 'OverwriteUserModified', true, @islogical );
    ip.addParameter( 'AppOverride', [  ], @( v )isempty( v ) || any( strcmpi( v, { 'c', 'gpu', 'fixed_point' } ) ) );
end
ip.parse( varargin{ : } );
opts = ip.Results;
if ~isempty( opts.AppOverride )
    opts.AppOverride = com.mathworks.toolbox.coder.app.GenericArtifact.valueOf( upper( opts.AppOverride ) );
end

if createMode
    checkTargetFileStatus( destProject, true, false );
    handleImporterActivities( 'cli2project', 'create', destProject, 'Silent', true );
else
    checkTargetFileStatus( destProject, true, true );
end

errorCode = char( com.mathworks.toolbox.coder.app.CodegenToProjectImporter.copyConfigParams(  ...
    java.io.File( srcProject ), java.io.File( destProject ), opts.AppOverride, false, opts.OverwriteUserModified ) );

switch errorCode
    case ''
        if ~opts.Silent
            if createMode
                messageKey = 'Coder:common:P2PProjectCreated';
            else
                messageKey = 'Coder:common:P2PProjectApplied';
            end
            fprintf( '\n%s\n\n', message( messageKey, srcProject, destProject ).getString(  ) );
        end
        result = {  };
    case 'FAILED_TO_LOAD_SOURCE'
        doError( 'Coder:common:P2PFailedToLoadProject', srcProject );
    case 'FAILED_TO_LOAD_TARGET'
        doError( 'Coder:common:P2PFailedToLoadProject', destProject );
    case 'INCOMPATIBLE_PROJECT_TYPES'
        doError( 'Coder:common:P2PIncompatibleProjectTypes', srcProject, destProject );
    case 'PROJECT_OPEN_IN_APP'
        doError( 'Coder:common:P2PProjectOpenInApp' );
    otherwise
        assert( false, 'Unrecognized ProjectCopyError error code "%s"', errorCode );
end
end


function isCurOpenPrj = isOpenAppProject( projectFile )
projectFile = char( java.io.File( projectFile ).getAbsolutePath(  ) );
appProject = getOpenAppProject(  );
if ~isempty( appProject )
    appProject = appProject.getFile(  ).getAbsolutePath(  );
    if ispc(  )
        isCurOpenPrj = strcmpi( projectFile, appProject );
    else
        isCurOpenPrj = strcmp( projectFile, appProject );
    end
else
    isCurOpenPrj = false;
end
end


function appProject = getOpenAppProject(  )
try
    appRegistry = com.mathworks.toolbox.coder.app.CoderRegistry.getInstance(  );
    appProject = appRegistry.getOpenProject(  );
catch
    appProject = [  ];
end
end


function projectFile = normalizeProjectFileArg( projectFile )
validateattributes( projectFile, { 'char', 'string' }, { 'scalartext' } );
projectFile = char( projectFile );
[ folder, projectName, ext ] = fileparts( projectFile );

if isempty( ext )
    ext = '.prj';
else
    if ispc(  )
        ext = lower( ext );
    end
    if ext ~= ".prj"
        doError( 'Coder:common:CliToAppInvalidFileExtension' );
    end
end
if isempty( folder )
    folder = pwd(  );
end
projectFile = fullfile( folder, [ projectName, ext ] );
end


function checkTargetFileStatus( projectFile, shouldBeWritable, shouldExistAlready )
if shouldExistAlready
    if ~isfile( projectFile )
        doError( 'Coder:common:CliToAppProjectFileNotFound', projectFile );
    end
else
    checkForExistingFile( projectFile, true );
end
if isOpenAppProject( projectFile )
    doError( 'Coder:common:CliToAppProjectAlreadyOpen' );
end
if shouldBeWritable
    checkIfFileWritable( projectFile );
end
end


function checkIfFileWritable( file )
failed = false;

folder = fileparts( file );
if ~isempty( folder ) && ~isfolder( folder )
    try
        mkdir( folder );
        rmdir( folder );
        return
    catch
        failed = true;
    end
end

if ~failed
    alreadyExists = isfile( file );
    fid = fopen( file, 'a+' );
    if fid ==  - 1
        failed = true;
    else
        fclose( fid );
        if ~alreadyExists
            delete( file );
        end
    end
end

if failed
    doError( 'Coder:common:CliToAppFileUnwritable', file );
end
end


function checkForExistingFile( projectFile, overwrite )
if isOpenAppProject( projectFile )
    doError( 'Coder:common:CliToAppOpenProject', getFilename( projectFile ) );
elseif isfile( projectFile )
    if overwrite
        try
            delete( projectFile );
        catch me %#ok<NASGU>
            doError( 'Coder:common:CliToAppFileAlreadyExists', projectFile );
        end
    else
        doError( 'Coder:common:CliToAppFileAlreadyExists', projectFile );
    end
end
end


function warnOfFailedValueEmbed( failedValues )
buffer = cell( 1, size( failedValues, 1 ) );
for i = 1:numel( buffer )
    [ ep, identifier ] = failedValues{ i, : };
    if ~isempty( ep )
        if ischar( identifier )
            buffer{ i } = message( 'Coder:common:CliToAppNamedInputEmbedFailed', identifier, ep.Name ).getString(  );
        else
            buffer{ i } = message( 'Coder:common:CliToAppInputEmbedFailed', identifier, ep.Name ).getString(  );
        end
    else
        buffer{ i } = message( 'Coder:common:CliToAppGlobalEmbedFailed', identifier ).getString(  );
    end
end
emlcprivate( 'ccwarningid', 'Coder:common:CliToAppValueEmbedFailures', strjoin( strcat( { sprintf( '\t' ) }, buffer ), '\n' ) );
end


function ip = createInputParser(  )
ip = inputParser(  );
ip.addParameter( 'Silent', false, @islogical );
end


function emptyOrValidate( value, varargin )
if ~isempty( value )
    validateattributes( value, varargin{ : } );
end
end


function doError( varargin )
emlcprivate( 'ccdiagnosticid', varargin{ : } );
end


function filename = getFilename( absoluteFile )
[ ~, filename, ext ] = fileparts( absoluteFile );
filename = [ filename, ext ];
end


function entryPoints = validateEntryPoints( entryPoints )
filter = false( size( entryPoints ) );
for i = 1:numel( entryPoints )
    entryPoint = entryPoints( i );
    if isempty( entryPoint.Name )
        filter( i ) = true;
        continue
    end
    absPath = getAbsolutePath( entryPoint );
    if ~isfile( absPath )
        doError( 'Coder:common:CliToAppEntryPointFileNotFound', entryPoint.Name );
    end
    if endsWith( lower( absPath ), '.p' )
        doError( 'Coder:common:CliToAppPFilesNotSupported' );
    end
end
entryPoints( filter ) = [  ];
end


function absPath = getAbsolutePath( entryPoint )

if ~isempty( entryPoint.CompleteName )
    absPath = entryPoint.CompleteName;
else
    absPath = entryPoint.UserInputName;
end
if ~java.io.File( absPath ).isAbsolute(  )
    absPath = fullfile( pwd, absPath );
end
end



