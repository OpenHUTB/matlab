function varargout = validateNetworkImpl( net, dlcfg, layerInfoMap, isCnnCodegenWorkflow, logAllErrors )

arguments
    net( 1, 1 ){ mustBeA( net, [ "SeriesNetwork", "DAGNetwork", "dlnetwork" ] ) }
    dlcfg{ mustBeA( dlcfg, 'coder.DeepLearningConfigBase' ) }
    layerInfoMap{ mustBeA( layerInfoMap, 'containers.Map' ) }
    isCnnCodegenWorkflow( 1, 1 )logical = false
    logAllErrors( 1, 1 )logical = false;

end

nargoutchk( 0, 1 );

errorHandler = coder.internal.DLCodegenErrorHandlerDispatcher.dispatchHandler( logAllErrors );
try
    iValidateNetwork( net, dlcfg, isCnnCodegenWorkflow, errorHandler );
catch ME
    rethrow( ME );
end

factory = dltargets.internal.compbuilder.CodegenLayerValidatorFactory;
validator = factory.createValidator( net, dlcfg, layerInfoMap, isCnnCodegenWorkflow, errorHandler );

try
    validator.validate(  );
catch ME
    rethrow( ME );
end

if nargout == 1
    varargout{ 1 } = errorHandler;
end

end


function hasSequenceInput = iCheckForSequenceInputs( net, inputLayers, outputLayers, isDLNetwork, targetlib, errorHandler )

hasSequenceInput = dltargets.internal.sharedNetwork.checkNetworkForSequenceInput( net, inputLayers );
if hasSequenceInput
    if ~isDLNetwork && ( numel( outputLayers ) > 1 || numel( inputLayers ) > 1 )
        error( message( 'dlcoder_spkg:cnncodegen:MIMONotSupportedForLSTMs' ) );
    end

    if isDLNetwork

        exampleInputs = net.getExampleInputs;
        if ~isempty( exampleInputs )
            for i = 1:numel( exampleInputs )
                exampleInputDims = dims( exampleInputs{ i } );
                imageInput = ( numel( strfind( exampleInputDims, 'S' ) ) == 2 ) ...
                    && ~contains( exampleInputDims, 'T' );
                featureInput = ~contains( exampleInputDims, 'S' ) ...
                    && ~contains( exampleInputDims, 'T' );
                anyImageOrFeatureInputs = imageInput || featureInput;
                if anyImageOrFeatureInputs
                    break ;
                end
            end
        else
            imageOrFeatureInputLayersBool = cellfun( @( layer )isa( layer, 'nnet.cnn.layer.ImageInputLayer' ) ...
                || isa( layer, 'nnet.cnn.layer.FeatureInputLayer' ), inputLayers );
            anyImageOrFeatureInputs = any( imageOrFeatureInputLayersBool );
        end

        if ~any( strcmp( targetlib, { 'cudnn', 'tensorrt', 'arm-compute', 'mkldnn', 'onednn', 'none' } ) )
            if anyImageOrFeatureInputs
                msg = message( 'dlcoder_spkg:dlnetwork:SequenceAndNonSequenceInputsNotSupported', targetlib );
                errorHandler.handleNetworkError( msg );
            end
        end
    end

end

end



function iValidateDLNetwork( dlnet, isCnnCodegenWorkflow, errorHandler )

if isCnnCodegenWorkflow
    msg = message( 'dlcoder_spkg:cnncodegen:DLNetworkNotSupportedForCnnCodegen' );
    errorHandler.handleNetworkError( msg );
end

assert( dlnet.Initialized, 'gpucoder:validate:UninitializedDlnetworkNotSupported' );

end


function iValidateDAGNetwork( dagNet, errorHandler )

iCheckForNonInitialStates( dagNet, errorHandler );
end


function iCheckForNonInitialStates( currentNet, errorHandler )
resetNet = resetState( currentNet );

numLayers = numel( currentNet.Layers );

for i = 1:numLayers
    currentLayer = currentNet.Layers( i );
    resetLayer = resetNet.Layers( i );
    assert( strcmp( currentLayer.Name, resetLayer.Name ), "Reset net and current net have different names" );

    if isa( currentLayer, 'nnet.cnn.layer.LSTMLayer' ) || isa( currentLayer, 'nnet.cnn.layer.BiLSTMLayer' )
        assert( isa( resetLayer, 'nnet.cnn.layer.LSTMLayer' ) || isa( resetLayer, 'nnet.cnn.layer.BiLSTMLayer' ),  ...
            'reset net and current net have different layers' );

        if ~isequal( currentLayer.HiddenState, resetLayer.HiddenState ) || ~isequal( currentLayer.CellState, resetLayer.CellState )
            msg = message( 'dlcoder_spkg:ValidateNetwork:NonInitialRnnState' );
            errorHandler.handleLayerError( currentLayer, msg );
        end

    elseif isa( currentLayer, 'nnet.cnn.layer.GRULayer' )
        assert( isa( resetLayer, 'nnet.cnn.layer.GRULayer' ),  ...
            'reset net and current net have different layers' );

        if ~isequal( currentLayer.HiddenState, resetLayer.HiddenState )
            msg = message( 'dlcoder_spkg:ValidateNetwork:NonInitialRnnState' );
            errorHandler.handleLayerError( currentLayer, msg );
        end
    end
end
end


function iValidateNetwork( net, dlcfg, isCnnCodegenWorkflow, errorHandler )

isQuantizedNet = deep.internal.quantization.isQuantizationEnabled( net );

if ~dlcoderfeature( 'QNetCodegen' ) && isQuantizedNet
    errorHandler.handleNetworkError( message( 'gpucoder:validate:QNetCodegenNotSupported' ) );
end

[ inputLayers, outputLayers ] = dltargets.internal.getIOLayers( net );
isDLNetwork = isa( net, 'dlnetwork' );
if isDLNetwork
    iValidateDLNetwork( net, isCnnCodegenWorkflow, errorHandler );
else
    iValidateDAGNetwork( net, errorHandler );
end

hasSequenceInput = iCheckForSequenceInputs( net, inputLayers, outputLayers, isDLNetwork, dlcfg.TargetLibrary, errorHandler );
switch lower( dlcfg.TargetLibrary )
    case 'tensorrt'
        dltargets.tensorrt.validateNetwork( inputLayers, hasSequenceInput, dlcfg, errorHandler );
    case 'cudnn'
        dltargets.cudnn.validateNetwork( inputLayers, dlcfg, errorHandler );
end

end


