function simInput = configureForDeployment( simInput )








%#function embedded.fi
%#function numerictype



arguments
    simInput Simulink.SimulationInput
end

product = "Simulink_Compiler";
[ status, msg ] = builtin( 'license', 'checkout', product );
if ~status
    product = extractBetween( msg, 'Cannot find a license for ', '.' );
    if ~isempty( product )
        error( message( 'simulinkcompiler:build:LicenseCheckoutError', product{ 1 } ) );
    end
    error( msg );
end

simInput = arrayfun( @( x )localConfigureSingleSimInput( x ), simInput );
end


function simInput = localConfigureSingleSimInput( simInput )
arguments
    simInput( 1, 1 )Simulink.SimulationInput
end
modelName = simInput.ModelName;





if ~isdeployed
    issueWarningIfModelIsNewerThanTarget( modelName );
end

simulink.compiler.internal.loadEnumTypes( modelName );

modelIndependentParameters = {  ...
    { 'simulationmode', 'r' },  ...
    { 'rapidacceleratoruptodatecheck', 'off' } ...
    };

for i = 1:length( modelIndependentParameters )
    simInput = simInput.setModelParameter(  ...
        modelIndependentParameters{ i }{ 1 },  ...
        modelIndependentParameters{ i }{ 2 } ...
        );
end
end




function issueWarningIfModelIsNewerThanTarget( modelName )
arguments
    modelName( 1, 1 )string
end



if ~isdeployed && ~bdIsLoaded( modelName )
    return
end

folders = Simulink.filegen.internal.FolderConfiguration( modelName, true, false );
buildDir = folders.RapidAccelerator.absolutePath( 'ModelCode' );

exeFilePath = rapid_accel_target_utils( 'get_exe_name', buildDir, modelName );
if ~exist( exeFilePath, 'file' )
    return
end
exeTimeStamp = dir( exeFilePath ).datenum;

modelFilePath = which( modelName );
assert( ~isempty( modelFilePath ) );
modelFileDirInfo = dir( modelFilePath );
if isempty( modelFileDirInfo )
    return
end
modelTimeStamp = modelFileDirInfo.datenum;

if modelTimeStamp > exeTimeStamp
    msg = message( 'simulinkcompiler:configure_for_deployment:TargetMayBeOutOfDate', modelName );
    w = MSLDiagnostic( msg );
    w.reportAsWarning(  );
end
end


