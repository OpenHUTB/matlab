function layer = accumulateLayer( nameValueArgs )

arguments
    nameValueArgs.Name{ mustBeText, iAssertValidLayerName } = ""
    nameValueArgs.OutputMode{ mustBeText } = "sequence"
    nameValueArgs.HasStateInputs( 1, 1 ){ iAssertBinary } = false
    nameValueArgs.HasStateOutputs( 1, 1 ){ iAssertBinary } = false
    nameValueArgs.AccumState = iDefaultState(  )
end


inputSize = [  ];
nameValueArgs = nnet.internal.cnn.layer.util.gatherParametersToCPU( nameValueArgs );
nameValueArgs.Name = convertStringsToChars( nameValueArgs.Name );
nameValueArgs.OutputMode = iAssertAndReturnValidOutputMode( nameValueArgs.OutputMode );
nameValueArgs.HasStateInputs = logical( nameValueArgs.HasStateInputs );
nameValueArgs.HasStateOutputs = logical( nameValueArgs.HasStateOutputs );
nameValueArgs.AccumState = iAssertAndReturnValidState( nameValueArgs.AccumState, nameValueArgs.HasStateInputs, "'AccumState'" );

import dnnfpga.macros.*


internalLayer = ACCUM( nameValueArgs.Name,  ...
    inputSize,  ...
    true,  ...
    iGetReturnSequence( nameValueArgs.OutputMode ),  ...
    nameValueArgs.HasStateInputs,  ...
    nameValueArgs.HasStateOutputs );


layer = ACCUMLayer( internalLayer );


if ~layer.HasStateInputs
    layer.AccumState = nameValueArgs.AccumState;
end
end

function tf = iGetReturnSequence( mode )
tf = true;
if strcmp( mode, 'last' )
    tf = false;
end
end

function state = iDefaultState(  )
state = [  ];
end

function validString = iAssertAndReturnValidOutputMode( value )
validString = validatestring( value, { 'sequence', 'last' } );
end


function iAssertBinary( value )
nnet.internal.cnn.options.OptionsValidator.assertBinary( value );
end

function iAssertValidFactor( value )
validateattributes( value, { 'numeric' }, { 'vector', 'real', 'nonnegative', 'finite' } );
end

function state = iAssertAndReturnValidState( state, hasStateInputs, name )

if hasStateInputs && ~isequal( state, iDefaultState(  ) )
    error( message( 'nnet_cnn:layer:LSTMLayer:SettingStateWithStateInputs', name ) );
end
end

function iAssertValidLayerName( name )
iEvalAndThrow( @(  ) ...
    nnet.internal.cnn.layer.paramvalidation.validateLayerName( name ) );
end

function iEvalAndThrow( func )

try
    func(  );
catch exception
    throwAsCaller( exception )
end
end


