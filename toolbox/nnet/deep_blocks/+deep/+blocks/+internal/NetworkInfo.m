classdef NetworkInfo < handle




properties ( Constant, Access = private )
SimTargetLibs = { 'mkldnn', 'onednn', 'cudnn', 'tensorrt' };
end 

properties ( SetAccess = private )
NetworkToLoad
TimeStamp
LayerNames
InputLayerNames
OutputLayerNames
ActivationNames
InputLayerSizes
NumInputs
NumOutputs
IsObjectDetector
IsDlNetwork
IsSequenceNetwork
HasSequenceOutput
Classes = categorical(  );
NumLoads = 0;



IsQuantizedNet( 1, 1 )logical = false
end 

properties ( Access = private )
MatlabCoderSpkgInstalled;
GpuCoderSpkgInstalled;
SimSupportedMap;
InputSizes = {  };
InputTypes = {  };
ResizeInput = false;
PredictEnabled = false;
InputFormats = {  };
ActivationLayers = {  };
PredictOutputSizes = {  };
ActivationSizes = {  };
PredictOutputTypes = {  };
ActivationTypes = {  };
Error = [  ];
end 

methods ( Access = public )
function obj = NetworkInfo( networkToLoad, timeStamp )
obj.NetworkToLoad = networkToLoad;
obj.TimeStamp = timeStamp;
net = obj.loadNetwork(  );

obj.IsObjectDetector = deep.blocks.internal.NetworkInfo.isObjectDetector( net );
if obj.IsObjectDetector
obj.Classes = categorical( net.ClassNames, net.ClassNames );
net = net.Network;
end 

obj.LayerNames = { net.Layers.Name };
obj.IsDlNetwork = isa( net, 'dlnetwork' );



obj.IsQuantizedNet = deep.internal.quantization.isQuantizationEnabled( net );


if ( obj.IsQuantizedNet && ~dlcoderfeature( 'QulNetInSL' ) )
error( message( 'deep_blocks:common:QuantizedNetNotSupported' ) );
end 

obj.MatlabCoderSpkgInstalled = dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
obj.GpuCoderSpkgInstalled = dlcoder_base.internal.isGpuCoderDLTargetsInstalled;

[ inputLayers, ~ ] = deep.blocks.internal.getIOLayers( net );
obj.IsSequenceNetwork = any( cellfun( @( layer )isa( layer,  ...
'nnet.cnn.layer.SequenceInputLayer' ), inputLayers ) );

if obj.IsDlNetwork
obj.InputLayerNames = net.InputNames';
obj.OutputLayerNames = net.OutputNames';
exampleInputs = net.getExampleInputs(  );
if isempty( exampleInputs )
obj.InputLayerSizes = cellfun(  ...
@( layer )layer.InputSize, inputLayers, 'UniformOutput', false );
else 
obj.InputLayerSizes = cellfun(  ...
@( placeholder )size( placeholder ), exampleInputs, 'UniformOutput', false );
end 
else 
inet = net.getInternalDAGNetwork(  );

obj.InputLayerNames = cellfun( @( layer )layer.Name,  ...
inet.InputLayers, 'UniformOutput', false );

obj.OutputLayerNames = cellfun( @( layer )layer.Name,  ...
inet.OutputLayers, 'UniformOutput', false );

obj.InputLayerSizes = inet.InputSizes;

obj.HasSequenceOutput = inet.HasSequenceOutput;

firstOutputLayer = net.Layers( strcmp( { net.Layers.Name }, net.OutputNames{ 1 } ) );
if inet.NumOutputs == 1 && isa( firstOutputLayer, 'nnet.cnn.layer.ClassificationOutputLayer' ) && ~obj.IsObjectDetector
obj.Classes = firstOutputLayer.Classes;
end 
end 

obj.NumInputs = numel( obj.InputLayerNames );
obj.NumOutputs = numel( obj.OutputLayerNames );

obj.computeSimSupported( net );



activationLayerNames = setdiff( obj.LayerNames, obj.OutputLayerNames, 'stable' );
numActivationNames = 0;
for i = 1:numel( net.Layers )
layer = net.Layers( i );
if any( strcmp( layer.Name, activationLayerNames ) )
numActivationNames = numActivationNames + layer.NumOutputs;
end 
end 

obj.ActivationNames = cell( 1, numActivationNames );
sortedLayers = deep.blocks.internal.getSortedLayers( net );
index = 1;
for i = 1:numel( sortedLayers )
layer = sortedLayers( i );
if any( strcmp( layer.Name, activationLayerNames ) )
if layer.NumOutputs == 1
obj.ActivationNames{ index } = layer.Name;
index = index + 1;
else 
for j = 1:layer.NumOutputs
obj.ActivationNames{ index } = [ layer.Name, '/', layer.OutputNames{ j } ];
index = index + 1;
end 
end 
end 
end 

obj.computeSimSupported( net );
end 

function [ predictOutputSizes, predictOutputTypes, activationSizes, activationTypes ] =  ...
getSizeInfo( obj, inputSizes, inputTypes, resizeInput, predictEnabled, inputFormats, activationLayers, mustRecompute )
assert( ~obj.IsObjectDetector, 'Cannot call getSizeInfo on an object detector' );
if nargin < 8

mustRecompute = obj.ResizeInput ~= resizeInput ||  ...
~isequal( inputSizes, obj.InputSizes ) ||  ...
~isequal( inputTypes, obj.InputTypes ) ||  ...
~isequal( predictEnabled, obj.PredictEnabled ) ||  ...
~isequal( inputFormats, obj.InputFormats ) ||  ...
~isequal( activationLayers, obj.ActivationLayers );
end 

if mustRecompute
obj.InputSizes = inputSizes;
obj.InputTypes = inputTypes;
obj.ResizeInput = resizeInput;
obj.PredictEnabled = predictEnabled;
obj.InputFormats = inputFormats;
obj.ActivationLayers = activationLayers;
obj.Error = [  ];

try 
obj.computeSizeInfo(  );
catch e
obj.Error = e;
end 
end 

if ~isempty( obj.Error )
rethrow( obj.Error );
end 

predictOutputSizes = obj.PredictOutputSizes;
predictOutputTypes = obj.PredictOutputTypes;

activationSizes = obj.ActivationSizes;
activationTypes = obj.ActivationTypes;
end 

function supported = isSimSupported( obj, simTargetLib, simTargetLang, nvps )

R36
obj( 1, 1 )
simTargetLib
simTargetLang
nvps.UpdateState( 1, 1 )logical = false;
end 

if strcmpi( simTargetLang, 'c' )
supported = false;
elseif obj.IsDlNetwork && nvps.UpdateState
supported = false;
else 
matlabCoderSpkgInstalled = dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
gpuCoderSpkgInstalled = dlcoder_base.internal.isGpuCoderDLTargetsInstalled;

if matlabCoderSpkgInstalled ~= obj.MatlabCoderSpkgInstalled ||  ...
gpuCoderSpkgInstalled ~= obj.GpuCoderSpkgInstalled
obj.computeSimSupported(  );
obj.MatlabCoderSpkgInstalled = matlabCoderSpkgInstalled;
obj.GpuCoderSpkgInstalled = gpuCoderSpkgInstalled;
end 

simTargetLib = deep.blocks.internal.NetworkInfo.sanitizeSimTargetLib( simTargetLib );
supported = obj.SimSupportedMap( simTargetLib );
end 
end 
end 

methods ( Access = private )
function net = loadNetwork( obj )
net = coder.loadDeepLearningNetwork( obj.NetworkToLoad );
obj.NumLoads = obj.NumLoads + 1;
end 

function computeSimSupported( obj, net )
obj.SimSupportedMap = containers.Map( 'KeyType', 'char', 'ValueType', 'logical' );
for i = 1:length( deep.blocks.internal.NetworkInfo.SimTargetLibs )
simTargetLib = deep.blocks.internal.NetworkInfo.SimTargetLibs{ i };
try 
dlconfig = coder.DeepLearningConfig( simTargetLib );
dltargets.internal.sdk.validateNetwork( net, dlconfig, dltargets.internal.formatInputSizes( obj.InputLayerSizes ) );
if ( obj.IsQuantizedNet && ~deep.blocks.internal.checkTargetLibSupportsQuantizer( simTargetLib ) )


obj.SimSupportedMap( simTargetLib ) = false;
else 
obj.SimSupportedMap( simTargetLib ) = true;
end 
catch 
obj.SimSupportedMap( simTargetLib ) = false;
end 
end 
end 

function computeSizeInfo( obj )
net = obj.loadNetwork(  );

inputSizes = obj.InputSizes;
if obj.ResizeInput
assert( ~obj.IsSequenceNetwork, 'ResizeInput is not supported for sequence inputs' );



for i = 1:numel( inputSizes )




assert( numel( obj.InputLayerSizes{ i } ) ~= 1, 'ResizeInput is not supported for feature input layer inputs' );
inputSizes{ i }( 1:2 ) = obj.InputLayerSizes{ i }( 1:2 );
end 
end 

info = deep.blocks.internal.computeInferenceInfo(  ...
net, inputSizes, obj.InputTypes,  ...
obj.InputFormats, obj.PredictEnabled, obj.ActivationLayers );

obj.PredictOutputSizes = info.PredictSizes;
obj.PredictOutputTypes = info.PredictTypes;
obj.ActivationSizes = info.ActivationSizes;
obj.ActivationTypes = info.ActivationTypes;
end 
end 

methods ( Access = private, Static )
function isDetector = isObjectDetector( net )
isDetector = isa( net, 'ssdObjectDetector' ) ||  ...
isa( net, 'yolov2ObjectDetector' ) ||  ...
isa( net, 'rcnnObjectDetector' ) ||  ...
isa( net, 'fastRCNNObjectDetector' ) ||  ...
isa( net, 'fasterRCNNObjectDetector' );
end 
function sanitizedSimTargetLib = sanitizeSimTargetLib( simTargetLib )
sanitizedSimTargetLib = lower( simTargetLib );
if strcmp( sanitizedSimTargetLib, 'mkl-dnn' )
sanitizedSimTargetLib = 'mkldnn';
elseif strcmp( sanitizedSimTargetLib, 'one-dnn' )
sanitizedSimTargetLib = 'onednn';
end 
end 
end 
end 
function out = getDim( sizeArray, dim )
if dim <= numel( sizeArray )
out = sizeArray( dim );
else 
out = 1;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdPyxCw.p.
% Please follow local copyright laws when handling this file.

