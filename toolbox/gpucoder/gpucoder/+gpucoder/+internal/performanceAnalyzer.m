function model = performanceAnalyzer( designFunction, inputs, opts )
arguments
    designFunction( 1, : )char{ mustBeNonempty }
    inputs cell{ mustNotBeCoderType( inputs ) } = {  }
    opts.InputTypes cell = {  }
    opts.Debug( 1, 1 ){ mustBeA( opts.Debug, 'logical' ) } = false
    opts.Config( 1, 1 ){ mustBeAGpuConfig( opts.Config ) } = coder.gpuConfig( 'dll' )
end

cfg = validateAndUpdateConfig( opts.Config );
validateInputsAndInputTypes( opts.InputTypes, inputs );

jsonFile = '';
if endsWith( designFunction, '.json' )
    jsonFile = designFunction;
    designFunction = '';
end
model = gpucoder.internal.profiling.GpuProfilerModel(  ...
    DesignFunction = designFunction,  ...
    JsonFile = jsonFile,  ...
    Inputs = inputs,  ...
    InputTypes = opts.InputTypes,  ...
    Config = cfg );

if isempty( jsonFile )
    model.runProfiling(  );
end

gpucoder.internal.profiling.GpuProfilerDialog( Model = model, Debug = opts.Debug );

end

function mustBeAGpuConfig( cfg )
if ~isa( cfg, 'coder.EmbeddedCodeConfig' ) ...
        || isempty( cfg.GpuConfig )
    throwAsCaller( MException( message( 'gpucoder:gui:profiler:ExpectedEmbeddedGpuConfig' ) ) );
end
end

function newcfg = validateAndUpdateConfig( cfg )
newcfg = cfg.copy(  );
if cfg.GenCodeOnly

    coder.internal.ccwarningid( 'gpucoder:gui:profiler:OverridingGenCodeOnlyOption' )
end
newcfg.GenCodeOnly = false;
newcfg.OutputType = 'DLL';
end

function mustNotBeCoderType( inputs )
for i = 1:numel( inputs )
    if isa( inputs{ i }, 'coder.Type' )
        throwAsCaller( MException( message( 'gpucoder:gui:profiler:UseInputTypesOption' ) ) );
    end
end
end

function validateInputsAndInputTypes( inputTypes, inputs )
if ~isempty( inputTypes ) && isempty( inputs )
    throwAsCaller( MException( message( 'gpucoder:gui:profiler:SpecifyInputs' ) ) );
end

end


