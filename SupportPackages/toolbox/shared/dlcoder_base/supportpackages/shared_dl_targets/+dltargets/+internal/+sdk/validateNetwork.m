































function validateNetwork( net, dlConfig, inputSizesOrDlarray, isCnnCodegenWorkflow )

R36
net( 1, 1 ){ mustBeA( net, [ "SeriesNetwork", "DAGNetwork", "dlnetwork" ] ), mustBeInitialized( net ) }
dlConfig( 1, 1 )coder.DeepLearningConfigBase
inputSizesOrDlarray
isCnnCodegenWorkflow( 1, 1 )logical = false;
end 

isDlnetwork = isa( net, 'dlnetwork' );


formattedInputSizes = iFormatInputSizes( inputSizesOrDlarray, isDlnetwork );



if all( cellfun( @( inputSize )isa( inputSize, 'dlarray' ) || isa( inputSize, 'deep.internal.PlaceholderArray' ), inputSizesOrDlarray ) )



inputFormats = cellfun( @dims, inputSizesOrDlarray, UniformOutput = false );
layerInfoMap = dltargets.internal.NetworkInfo.constructLayerInfoMap( net, formattedInputSizes, inputFormats );
else 
layerInfoMap = dltargets.internal.NetworkInfo.constructLayerInfoMap( net, formattedInputSizes );
end 

try 
dltargets.internal.sharedNetwork.validateNetworkImpl( net, dlConfig, layerInfoMap, isCnnCodegenWorkflow );
catch ME
throwAsCaller( ME );
end 
end 

function inputSizes = iFormatInputSizes( inputSizes, isDlnetwork )

numNetworkInputs = numel( inputSizes );
if ~( iscell( inputSizes ) &&  ...
( numel( size( inputSizes ) ) < 3 ) &&  ...
( ( size( inputSizes, 1 ) == 1 ) || ( size( inputSizes, 2 ) == 1 ) ) &&  ...
( numNetworkInputs > 0 ) )
errorId = 'dlcoder_spkg:ValidateNetwork:malformedInput';
throwAsCaller( MException( errorId, getString( message( errorId ) ) ) );
end 

for i = 1:numNetworkInputs
inputSize = inputSizes{ i };
if isa( inputSize, 'dlarray' ) || isa( inputSize, 'deep.internal.PlaceholderArray' )
if ~isDlnetwork
errorId = 'dlcoder_spkg:ValidateNetwork:invalidDAGNetworkInput';
throwAsCaller( MException( errorId, getString( message( errorId ) ) ) );
end 

if isempty( dims( inputSize ) )
errorId = 'dlcoder_spkg:ValidateNetwork:malformedDlarray';
throwAsCaller( MException( errorId, getString( message( errorId ) ) ) );
end 

inputSizes{ i } = iExtractInputSizeFromDlarray( inputSize );
elseif isnumeric( inputSize )

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...

if ~( ( size( inputSize, 1 ) == 1 ) && ( size( inputSize, 2 ) == 4 ) )
errorId = 'dlcoder_spkg:ValidateNetwork:malformedNumericArray';
throwAsCaller( MException( errorId, getString( message( errorId ) ) ) );
end 
else 
errorId = 'dlcoder_spkg:ValidateNetwork:malformedInput';
throwAsCaller( MException( errorId, getString( message( errorId ) ) ) );
end 
end 
end 

function inputSize = iExtractInputSizeFromDlarray( dlarrayInput )
inputSize = dltargets.internal.utils.NetworkValidationUtils.convertFormattedDlarrayToCodegenSizes( dlarrayInput );
end 

function mustBeInitialized( net )

if isa( net, 'dlnetwork' ) && ~net.Initialized
error( message( 'gpucoder:validate:UninitializedDlnetworkNotSupported' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp919Cg3.p.
% Please follow local copyright laws when handling this file.

