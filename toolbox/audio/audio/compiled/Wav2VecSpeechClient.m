classdef Wav2VecSpeechClient < handle










properties ( SetAccess = immutable, GetAccess = public )
Segmentation
TimeStamps
end 
properties ( Access = private, Transient )
Learnables
end 
properties ( Access = private, Constant )
Dictionary = [ "<pad>", "<s>", "</s>", "<unk>", "|", "e", "t", "a", "o", "n", "i", "h", "s", "r", "d", "l", "u", "m", "w", "c", "f", "g", "y", "p", "b", "v", "k", "'", "x", "j", "q", "z" ];
DictionaryMap = containers.Map( [ "<pad>", "<s>", "</s>", "<unk>", "|", "e", "t", "a", "o", "n", "i", "h", "s", "r", "d", "l", "u", "m", "w", "c", "f", "g", "y", "p", "b", "v", "k", "'", "x", "j", "q", "z" ], 1:32 )
end 
methods 
function obj = Wav2VecSpeechClient( nvargs )
R36
nvargs.Segmentation( 1, : )char{ mustBeMember( nvargs.Segmentation, [ "word", "none" ] ) } = "word"
nvargs.TimeStamps( 1, 1 ){ mustBeNumericOrLogical } = false
end 

systemName = "wav2vec2-base-960";
matFileName = sprintf( '%s.mat', systemName );
coder.internal.errorIf( ~exist( matFileName, 'file' ),  ...
'audio:speech2text:MATFileNotFound',  ...
systemName );

coder.internal.errorIf( nvargs.TimeStamps && strcmp( nvargs.Segmentation, "none" ),  ...
'audio:speech2text:TimeStampsNotSupported',  ...
'Segmentation', '"none"' )

model = load( matFileName );

obj.Learnables = model.Learnables;

obj.TimeStamps = nvargs.TimeStamps;
obj.Segmentation = nvargs.Segmentation;
end 
end 
methods ( Hidden )
function output = transcribe( obj, audioIn, fs )

if ~audioutil(  )
errID = "audio:audioutil:licenseNotFound";
error( errID, getString( message( errID, "speech2text" ) ) );
end 
if ~deeplearningutil(  )
errID = "audio:audioutil:licenseNotFound";
error( errID, getString( message( errID, "wav2vec 2.0" ) ) );
end 

validateattributes( audioIn, [ "single", "double" ], [ "column", "nonnan", "finite" ], "speech2text", "audioIn" )
validateattributes( fs, [ "single", "double" ], [ "scalar", "positive", "nonnan", "finite" ], "speech2text", "fs" )


coder.internal.errorIf( numel( audioIn ) < fs * 0.05,  ...
"audio:speech2text:AudioInputTooShort",  ...
"50" )


if fs ~= 16e3
audioIn = cast( resample( double( audioIn ), 16e3, double( fs ) ), like = audioIn );
fs = 16e3;
end 
numSamples = size( audioIn, 1 );

X = audioIn;


offset = 1e-5;
X = ( X - mean( X ) ) / sqrt( var( X ) + offset );


X = dlarray( X );


X = featureEncoder( X, obj.Learnables.featureEncoder );


X = positionalEncoder( X, obj.Learnables.positionalEncoder );


X = transformerEncoder( X, obj.Learnables.transformerEncoder );


X = gather( extractdata( X ) );


txt = textDecoder( X, obj.Dictionary );

if erase( txt, "|" ) == ""

if strcmp( obj.Segmentation, "none" )
output = "";
else 
if obj.TimeStamps
output = table( "", NaN, [ NaN, NaN ], VariableNames = [ "Transcript", "Confidence", "TimeStamps" ] );
else 
output = table( "", NaN, VariableNames = [ "Transcript", "Confidence" ] );
end 
end 
else 


ratio = numSamples / size( X, 2 );
[ txt, conf, sampleStamps ] = audio.internal.ctcAlignment( X, obj.DictionaryMap, txt, ratio );


if strcmp( obj.Segmentation, "none" )

txt = strjoin( txt( : ) );
output = txt;
else 
if obj.TimeStamps
timeStamps = ( sampleStamps - 1 ) / fs;
output = table( txt, conf, timeStamps, VariableNames = [ "Transcript", "Confidence", "TimeStamps" ] );
else 
output = table( txt, conf, VariableNames = [ "Transcript", "Confidence" ] );
end 
end 
end 
end 
end 
end 

function Y = featureEncoder( X, params )



X = dlconv( X, params.conv1d_1.Weights, 0, Stride = 5, DataFormat = "TCB", WeightsFormat = "TCU" );
X = instancenorm( X, params.instancenorm_1.Offset, params.instancenorm_1.Scale, DataFormat = "TCB" );
X = customGELU( X );

X = dlconv( X, params.conv1d_2.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = dlconv( X, params.conv1d_3.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = dlconv( X, params.conv1d_4.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = dlconv( X, params.conv1d_5.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = dlconv( X, params.conv1d_6.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = dlconv( X, params.conv1d_7.Weights, 0, Stride = 2, DataFormat = "TCB", WeightsFormat = "TCU" );
X = customGELU( X );

X = layernorm( X, params.layernorm_1.Offset, params.layernorm_1.Scale, DataFormat = "TCB" );

Y = pagemtimes( params.fc_1.Weights, X' ) + params.fc_1.Bias;
end 

function Y = positionalEncoder( X, params )





Xe = positionalEmbedding( X, params.positionalEmbedding );


X = Xe + X;
Y = layernorm( X, params.layernorm.offset, params.layernorm.scaleFactor, DataFormat = "CB" );

function z = positionalEmbedding( x, params )






z = dlconv( x, params.Weights, params.Bias, DataFormat = "CTB", WeightsFormat = "TUCU", Stride = 1, Padding = 64 );
z = z( :, 1:end  - 1 );


z = customGELU( z );
end 
end 

function Y = transformerEncoder( X, params )




X = encoderBlock( X, params.block_1 );
X = encoderBlock( X, params.block_2 );
X = encoderBlock( X, params.block_3 );
X = encoderBlock( X, params.block_4 );
X = encoderBlock( X, params.block_5 );
X = encoderBlock( X, params.block_6 );
X = encoderBlock( X, params.block_7 );
X = encoderBlock( X, params.block_8 );
X = encoderBlock( X, params.block_9 );
X = encoderBlock( X, params.block_10 );
X = encoderBlock( X, params.block_11 );
X = encoderBlock( X, params.block_12 );

Y = pagemtimes( params.fc.Weights, X ) + params.fc.Bias( : );

function X = encoderBlock( X, params )







xa = multiheadAttention( X, params.multiheadAttention );


X = X + xa;
X = layernorm( X, params.layernorm_1.offset, params.layernorm_1.scaleFactor, DataFormat = "CB" );


xff = pagemtimes( params.fc_1.Weights, X ) + params.fc_1.Bias( : );
xff = customGELU( xff );
xff = pagemtimes( params.fc_2.Weights, xff ) + params.fc_2.Bias( : );


X = X + xff;
X = layernorm( X, params.layernorm_2.offset, params.layernorm_2.scaleFactor, DataFormat = "CB" );

end 
end 

function A = multiheadAttention( X, params )




numHeads = 12;


K = pagemtimes( params.fc_1.Weights, X ) + params.fc_1.Bias( : );
V = pagemtimes( params.fc_2.Weights, X ) + params.fc_2.Bias( : );
Q = pagemtimes( params.fc_3.Weights, X ) + params.fc_3.Bias( : );


A = scaledDotProductAttention( Q, K, V, numHeads );


A = iMergeHeads( A );


A = pagemtimes( params.fc_4.Weights, A ) + params.fc_4.Bias( : );

function A = scaledDotProductAttention( Q, K, V, numHeads )







numFeatures = size( K, 1 );


K = iSplitHeadsQ( K, numFeatures, numHeads );
Q = iSplitHeads( Q, numFeatures, numHeads );
W = pagemtimes( K, Q );


W = W ./ sqrt( size( Q, 1 ) );


W = softmax( W, DataFormat = "CTUB" );


V = iSplitHeads( V, numFeatures, numHeads );
A = pagemtimes( V, W );

function Z = iSplitHeads( X, numFeatures, numHeads )




X = reshape( X, numFeatures / numHeads, numHeads, [  ], 1 );
Z = permute( X, [ 1, 3, 2 ] );
end 
function Z = iSplitHeadsQ( X, numFeatures, numHeads )



X = reshape( X, numFeatures / numHeads, numHeads, [  ], 1 );
Z = permute( X, [ 3, 1, 2 ] );
end 
end 
function Z = iMergeHeads( X )


X = permute( X, [ 1, 3, 2 ] );
Z = reshape( X, size( X, 1 ) * size( X, 2 ), [  ] );
end 

end 

function txt = textDecoder( Y, dict )




[ ~, argmax ] = max( Y, [  ], 1 );

txt = dict( argmax );

isChangePoint = diff( [ 0, argmax ] ) ~= 0;
txt( ~isChangePoint ) = [  ];
txt = join( txt, "" );

txt = erase( txt, "<pad>" );


if endsWith( txt, "|" )
txt = extractBefore( txt, strlength( txt ) );
end 
end 

function Z = customGELU( x )



Z = 0.5 * x .* ( 1 + tanh( sqrt( 2 / pi ) * ( x + 0.044715 * ( x .^ 3 ) ) ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDR8r7J.p.
% Please follow local copyright laws when handling this file.

