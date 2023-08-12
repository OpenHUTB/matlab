




classdef ( Abstract )BaseGraphBuilder < handle

methods ( Abstract )


finalize( this )


graph = createGraph( this, dutName )



createIO( this, dut, inputNames, inputTypes, outputNames, outputTypes )





newSubGraph = beginSubGraph( this, name, description, subGraphInfo )




setSubGraph( subGraphNode )


endSubGraph( this )


subGraphNode = getCurrentSubGraphNode( this )


name = getCurrentSubGraphName( this )





newSubGraphNode = copySubGraph(  ...
this, name, oldSubGraphNode, description, subGraphInfo )


[ inp, inpIdx ] = addInput( this, name, typeInfo )
[ out, outIdx ] = addOutput( this, name, typeInfo )


setType( this, node, type, varargin )


setInitialValue( this, node, value )



connect( this, node1, node2 )


setSignalName( this, node, name )


isit = isValidIdentifier( this, name )



vals = setupNewNode( this, description, typeInfo )


node = finalizeNewNode( this, node, vals )





val = generateSourceCodeComments( ~ )


val = generateTraceability( ~ )


traceCmt = getNodeTraceability( ~, ~ )




setNodeTraceabilityOverride( ~, ~ )

traceCmt = getNodeTraceabilityOverride( ~ )


val = generateUserComments( ~ )




setUserCommentForFunction( ~, ~ )


setInliningForCurrentFunction( ~, ~ )
end 

methods 




function node = createFromNode( this, description, typeInfo, tag )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateFromNode( vals, tag );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateFromNode( this, vals, tag )%#ok<STOUT,INUSD>
error( 'unimplemented: from' )
end 

function node = createGotoNode( this, description, typeInfo, tag )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateGotoNode( vals, tag );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateGotoNode( this, vals, tag )%#ok<STOUT,INUSD>
error( 'unimplemented: goto' )
end 

function node = createUnitDelayNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateUnitDelayNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateUnitDelayNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: unit delay' )
end 

function node = createDelayNode( this, description, typeInfo, color, delayLength )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDelayNode( vals, color, delayLength );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDelayNode( this, vals, color, delayLength, inputNode )%#ok<STOUT,INUSD>
error( 'unimplemented: delay' )
end 



function node = createSumNode( this, description, typeInfo, dimension )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSumNode( vals, dimension );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSumNode( this, vals, dimension )%#ok<STOUT,INUSD>
error( 'unimplemented: sum' )
end 

function node = createTreeSumNode( this, description, typeInfo, dimension )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateTreeSumNode( vals, dimension );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateTreeSumNode( this, vals, dimension )%#ok<STOUT,INUSD>
error( 'unimplemented: hdl.treesum' )
end 

function node = createProdNode( this, description, typeInfo, dimension )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateProdNode( vals, dimension );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateProdNode( this, vals, dimension )%#ok<STOUT,INUSD>
error( 'unimplemented: prod' )
end 

function node = createTreeProdNode( this, description, typeInfo, dimension )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateTreeProdNode( vals, dimension );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateTreeProdNode( this, vals, dimension )%#ok<STOUT,INUSD>
error( 'unimplemented: hdl.treeprod' )
end 

function node = createTableLookupNDNode( this, description, typeInfo, paramVals )
R36
this;
description;
typeInfo;
paramVals.dimension;
paramVals.tableData;
paramVals.breakPointData;
paramVals.interpolation;
paramVals.extrapolation;
end 
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateTableLookupNDNode( vals, paramVals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateTableLookupNDNode( this, vals, paramVals )%#ok<STOUT,INUSD>
error( 'unimplemented: hdl.tablelookupND' )
end 

function node = createAddNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateAddNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateAddNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: add' )
end 

function node = createSubNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSubNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSubNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: sub' )
end 



function node = createGainNode( this, description, typeInfo, gainAmount, useDotMul, KTimesU )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateGainNode( vals, gainAmount, useDotMul, KTimesU );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateGainNode( this, vals, gainAmount, useDotMul, KTimesU )%#ok<STOUT,INUSD>
error( 'unimplemented: gain' )
end 

function node = createDotMulNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDotMulNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDotMulNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: dotmul' )
end 

function node = createMulNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateMulNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateMulNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: mul' )
end 

function node = createDotDivNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDotDivNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDotDivNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: dotdiv' )
end 

function node = createDivNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDivNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDivNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: Div' )
end 

function node = createUminusNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateUminusNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateUminusNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: uminus' )
end 

function node = createSignNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSignNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSignNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: sign' )
end 

function node = createToWorkspaceNode( this, description, typeInfo, outVarName )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateToWorkspaceNode( vals, outVarName );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateToWorkspaceNode( this, vals, outVarName )%#ok<STOUT,INUSD>
error( 'unimplemented: to workspace' )
end 

function node = createDTCNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDTCNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDTCNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: dtc' )
end 

function node = createReinterpretNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateReinterpretNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateReinterpretNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: reinterpret' )
end 

function node = createBitsetNode( this, description, typeInfo, bitIdx, toVal )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitsetNode( vals, bitIdx, toVal );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitsetNode( this, vals, bitIdx, toVal )%#ok<STOUT,INUSD>
error( 'unimplemented: bitset' )
end 

function node = createAbsNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateAbsNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateAbsNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: abs' )
end 

function node = createSqrtNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSqrtNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function node = createMinMaxNode( this, description, typeInfo, fcn )
assert( ismember( fcn, { 'min', 'max' } ) )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateMinMaxNode( vals, fcn );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateMinMaxNode( this, vals, fcn )%#ok<STOUT,INUSD>
error( 'unimplemented: min/max' )
end 

function [ node, vals ] = instantiateSqrtNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: sqrt' )
end 

function node = createCordicTrigNode( this, description, typeInfo, fcnName, iterNum )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateCordicTrigNode( vals, fcnName, iterNum );
node = this.finalizeNewNode( node, vals );
this.postFinalizeCordicTrigNode( node, vals );
end 

function [ node, vals ] = instantiateCordicTrigNode( this, vals, fcnName, iterNum )%#ok<STOUT,INUSD>
error( 'unimplemented: cordic trig' )
end 

function postFinalizeCordicTrigNode( this, node, vals )%#ok<INUSD>
error( 'unimplemented: post finalize cordic trig' )
end 

function node = createTrigNode( this, description, typeInfo, fcn )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateTrigNode( vals, fcn );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateTrigNode( this, vals, fcn )%#ok<STOUT,INUSD>
error( 'unimplemented: trig' )
end 

function node = createMathNode( this, description, typeInfo, fcn )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateMathNode( vals, fcn );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateMathNode( this, vals, fcn )%#ok<STOUT,INUSD>
error( 'unimplemented: math' )
end 

function node = createRoundingNode( this, description, typeInfo, fcn )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateRoundingNode( vals, fcn );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateRoundingNode( this, vals, fcn )%#ok<STOUT,INUSD>
error( 'unimplemented: rounding functions' )
end 

function node = createArithShiftNode( this, description, typeInfo, numberSource, direction )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateArithShiftNode( vals, numberSource, direction );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateArithShiftNode( this, vals, numberSource, direction )%#ok<STOUT,INUSD>
error( 'unimplemented: arithshift' )
end 

function node = createBitsliceNode( this, description, typeInfo, leftIdx, rightIdx )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitsliceNode( vals, leftIdx, rightIdx );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitsliceNode( this, vals, leftIdx, rightIdx )%#ok<STOUT,INUSD>
error( 'unimplemented: bitslice' )
end 



function node = createBitshiftNode( this, description, typeInfo, kind, shiftBy )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitshiftNode( vals, kind, shiftBy );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitshiftNode( this, vals, kind, shiftBy )%#ok<STOUT,INUSD,INUSL>
error( [ 'unimplemented: ', kind ] )
end 


function node = createVarArithShiftNode( this, description, typeInfo, direction )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateVarArithShiftNode( vals, direction );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateVarArithShiftNode( this, vals, direction )%#ok<STOUT,INUSD>
error( 'unimplemented: varbitsla' )
end 

function node = createBitconcatNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitconcatNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitconcatNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: bitconcat' )
end 

function node = instantiateConstant( this, const )
description = const.Description;
name = const.Name;
value = const.Value;
type = internal.mtree.Type.fromValue( value );
typeInfo = internal.mtree.NodeTypeInfo( [  ], type );

node = this.createInstantiatedConstantNode( description, typeInfo, name, value );
end 

function node = createInstantiatedConstantNode( this, description, typeInfo, name, value )
vals = this.setupNewNode( description, typeInfo );

if ~this.isValidIdentifier( name )
vals.name = 'const_expression';
else 
vals.name = name;
end 

[ node, vals ] = this.instantiateInstantiatedConstantNode( vals, value );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateInstantiatedConstantNode( this, vals, value )%#ok<STOUT,INUSD>
error( 'unimplemented: instantiated-constant' )
end 

function node = createTunableConstantNode( this, description, typeInfo, name )
vals = this.setupNewNode( description, typeInfo );
vals.name = name;
[ node, vals ] = this.instantiateTunableConstantNode( vals, name );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateTunableConstantNode( this, vals, name )%#ok<STOUT,INUSD>
error( 'unimplemented: tunable-constant' );
end 

function node = createDisplayNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDisplayNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDisplayNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: display' )
end 



function node = createRelOpNode( this, description, typeInfo, kind )
vals = this.setupNewNode( description, typeInfo );
switch upper( kind )
case 'EQ'
kind = '==';
case 'NE'
kind = '~=';
case 'GT'
kind = '>';
case 'GE'
kind = '>=';
case 'LT'
kind = '<';
case 'LE'
kind = '<=';
end 
[ node, vals ] = this.instantiateRelOpNode( vals, kind );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateRelOpNode( this, vals, kind )%#ok<STOUT,INUSD>
error( 'unimplemented: relop' )
end 

function node = createFloatRelOpNode( this, description, typeInfo, fcn )
vals = this.setupNewNode( description, typeInfo );
switch upper( fcn )
case 'ISINF'
fcn = 'isInf';
case 'ISNAN'
fcn = 'isNaN';
case 'ISFINITE'
fcn = 'isFinite';
end 
[ node, vals ] = this.instantiateFloatRelOpNode( vals, fcn );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateFloatRelOpNode( this, vals, kind )%#ok<STOUT,INUSD>
error( 'unimplemented: float_relop' )
end 



function node = createCompareToConstantNode( this, description, typeInfo, kind, value )
vals = this.setupNewNode( description, typeInfo );
switch upper( kind )
case 'EQ'
kind = '==';
case 'NE'
kind = '~=';
case 'GT'
kind = '>';
case 'GE'
kind = '>=';
case 'LT'
kind = '<';
case 'LE'
kind = '<=';
end 
[ node, vals ] = this.instantiateCompareToConstantNode( vals, kind, value );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateCompareToConstantNode( this, vals, kind, value )%#ok<STOUT,INUSD>
error( 'unimplemented: compare to constant' )
end 


function node = createLogicOpNode( this, description, typeInfo, kind )
vals = this.setupNewNode( description, typeInfo );
switch upper( kind )
case 'ANDAND'
kind = '&&';
case 'OROR'
kind = '||';
case 'NOT'
kind = '~';
case 'XOR'
kind = 'xor';
end 
[ node, vals ] = this.instantiateLogicOpNode( vals, kind );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateLogicOpNode( this, vals, kind )%#ok<STOUT,INUSD>
error( 'unimplemented: logic operator' )
end 


function node = createBitwiseOpNode( this, description, typeInfo, kind )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitwiseOpNode( vals, kind );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitwiseOpNode( this, vals, kind )%#ok<STOUT,INUSD>
error( 'unimplemented: bitwise operator' )
end 


function node = createBitReduceNode( this, description, typeInfo, kind )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitReduceNode( vals, kind );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitReduceNode( this, vals, kind )%#ok<STOUT,INUSD>
error( 'unimplemented: bitwise reduction operator' )
end 


function [ node, vals ] = createBitRotNode( this, description, typeInfo, kind, shiftAmount )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBitRotNode( vals, kind, shiftAmount );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateBitRotNode( this, vals, kind, shiftAmount )%#ok<STOUT,INUSD,INUSL>
error( [ 'unimplemented: ', kind ] )
end 

function node = createDotExpNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateDotExpNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateDotExpNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: dotexp' )
end 

function node = createExpNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateExpNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateExpNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: exp' )
end 




function node = createRealImagToComplexNode( this, description, typeInfo, mode, constPart )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateRealImagToComplexNode( vals, mode, constPart );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateRealImagToComplexNode( this, vals, mode )%#ok<STOUT,INUSD>
error( 'unimplemented: real to complex' )
end 



function node = createComplexToRealImagNode( this, description, typeInfo, fcnName )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateComplexToRealImagNode( vals, fcnName );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateComplexToRealImagNode( this, vals, mode )%#ok<STOUT,INUSD>
error( 'unimplemented: complex to real/imag' )
end 


function node = createMatlabFunctionNode( this, description, typeInfo, fcnName, varargin )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateMatlabFunctionNode( vals, fcnName, varargin{ : } );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateMatlabFunctionNode( this, vals, varargin )%#ok<STOUT,INUSL>
error( [ 'unimplemented: matlab-function : ', varargin{ 1 } ] );
end 



function node = createSwitchNode( this, description, typeInfo, kind, varargin )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSwitchNode( vals, kind, varargin{ : } );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSwitchNode( this, vals, kind, threshold )%#ok<STOUT,INUSD>
error( 'unimplemented: switch' )
end 

function node = createMultiportSwitchNode( this, description, typeInfo, inputmode, dpOrder )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateMultiportSwitchNode( vals, inputmode, dpOrder );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateMultiportSwitchNode( this, vals, inputmode, dpOrder )%#ok<STOUT,INUSD>
error( 'unimplemented: multiport switch' )
end 

function node = createReshapeNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateReshapeNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateReshapeNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: reshape' )
end 








function node = createSubassignNode( this, description, typeInfo, indexArray, isConditional )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSubassignNode( vals, indexArray, isConditional );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSubassignNode( this, vals, indexArray, isConditional )%#ok<STOUT,INUSD>
error( 'unimplemented: subassign' );
end 








function node = createSubscrNode( this, description, typeInfo, indexArray, isConditional )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateSubscrNode( vals, indexArray, isConditional );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateSubscrNode( this, vals, indexArray, isConditional )%#ok<STOUT,INUSD>
error( 'unimplemented: subscr' );
end 




function [ indexOptions, indexParams ] = getIndexOptionArrays( ~, indexArray, isSubassign )
numIndices = numel( indexArray );
indexOptions = cell( 1, numIndices );
indexParams = cell( 1, numIndices );

for i = 1:numIndices
idx = indexArray{ i };

if isempty( idx )

if isSubassign
indexOptions{ i } = 'Assign all';
else 
indexOptions{ i } = 'Select all';
end 
indexParams{ i } =  - 1;
elseif isa( idx, 'internal.mtree.Constant' )

indexOptions{ i } = 'Index vector (dialog)';
indexParams{ i } = double( idx.Value );
elseif isa( idx, 'internal.mtree.Type' )

indexOptions{ i } = 'Index vector (port)';
indexParams{ i } =  - 1;
else 
error( 'unknown index array value' );
end 
end 
end 

function node = createArrayConcatNode( this, description, typeInfo, concatDimension )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateArrayConcatNode( vals, concatDimension );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateArrayConcatNode( ~, vals, concatDimension )%#ok<STOUT,INUSD>
error( 'unimplemented: arrayconcat' )
end 

function node = createPIRSystemObjectNode( this, description, typeInfo, sysObjInstance )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiatePIRSystemObjectNode( vals, sysObjInstance );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiatePIRSystemObjectNode( ~, vals, sysObjInstance )%#ok<STOUT,INUSD>
error( 'unimplemented: PIRSystemObject' )
end 


function node = createBusSelectorNode( this, description, typeInfo, busElementName )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBusSelectorNode( vals, busElementName );
node = this.finalizeNewNode( node, vals );
end 



function [ node, vals ] = instantiateBusSelectorNode( ~, vals, busElementName )%#ok<STOUT,INUSD>
error( 'unimplemented: busselector' )
end 


function node = createBusCreatorNode( this, description, typeInfo, busObject )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBusCreatorNode( vals, busObject );
node = this.finalizeNewNode( node, vals );
end 



function [ node, vals ] = instantiateBusCreatorNode( ~, vals, busObject )%#ok<STOUT,INUSD>
error( 'unimplemented: buscreator' )
end 


function node = createBusAssignmentNode( this, description, typeInfo, busElementName )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBusAssignmentNode( vals, busElementName );
node = this.finalizeNewNode( node, vals );
end 



function [ node, vals ] = instantiateBusAssignmentNode( ~, vals, busElementName )%#ok<STOUT,INUSD>
error( 'unimplemented: busassignment' )
end 


function node = createBusConcatenateNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateBusConcatenateNode( vals );
node = this.finalizeNewNode( node, vals );
end 


function [ node, vals ] = instantiateBusConcatenateNode( ~, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: busconcatenate' )
end 

function node = createNoopNode( this, description, typeInfo )
vals = this.setupNewNode( description, typeInfo );
[ node, vals ] = this.instantiateNoopNode( vals );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateNoopNode( this, vals )%#ok<STOUT,INUSD>
error( 'unimplemented: noop' );
end 

function node = createCounterNode( this, description, typeInfo, name, start, step, stop )
vals = this.setupNewNode( description, typeInfo );
vals.name = name;
[ node, vals ] = this.instantiateCounterNode( vals, start, step, stop );
node = this.finalizeNewNode( node, vals );
end 

function [ node, vals ] = instantiateCounterNode( vals, start, step, stop )%#ok<STOUT,INUSD>
error( 'unimplemented: counter' );
end 


function processInliningForCurrentFunction( this, inlineOptStr )
switch inlineOptStr
case 'always'
inlineOpt = 0;
case 'never'
inlineOpt = 1;
case 'default'
inlineOpt = 2;
otherwise 
error( [ 'unexpected inline pragma ''', inlineOptStr, ''' found' ] );
end 
this.setInliningForCurrentFunction( inlineOpt );
end 
end 

methods ( Static )

function s = toString( value )
s = '';

if isnumerictype( value )
s = asOneLine( tostring( value ) );

elseif isfimath( value )
if isequal( value, hdlfimath )
s = 'hdlfimath';
elseif isequal( value, fimath )
s = 'fimath';
else 
s = asOneLine( tostring( value ) );
end 

elseif isfi( value )
nt = numerictype( value );
fm = fimath( value );
v = double( value );
s = sprintf( 'fi(%s, %d, %d, %d, %s)',  ...
internal.ml2pir.BaseGraphBuilder.toString( v ),  ...
nt.SignednessBool, nt.WordLength, nt.FractionLength,  ...
internal.ml2pir.BaseGraphBuilder.toString( fm ) );

elseif isnumeric( value )
value_str = mat2str( value, 21 );
if isa( value, 'double' )

s = value_str;
else 
s = sprintf( '%s(%s)', class( value ), value_str );
end 


elseif ischar( value )
s = value;

elseif islogical( value )
alltrue = all( value, 'all' );
allfalse = ~alltrue && all( ~value, 'all' );

if alltrue || allfalse
if alltrue
s = 'true';
else 
s = 'false';
end 

if ~isscalar( value )
s = [ s, '(', mat2str( size( value ) ), ')' ];
end 
else 
s = mat2str( value );
end 

elseif isa( value, 'internal.mtree.Constant' )
s = internal.ml2pir.BaseGraphBuilder.toString( value.Value );
end 

function s = asOneLine( s )
s = strjoin( strsplit( s, '...' ) );
s = strjoin( strsplit( s, newline ) );
s = strjoin( strsplit( s, ',  ' ), ', ' );
end 
end 

end 

end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmp2_nD0d.p.
% Please follow local copyright laws when handling this file.

