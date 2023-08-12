




classdef RuntimeFcnsInfo

properties 

modelName{ mustBeTextScalar } = ''


inputs slsim.PortSignalSource = slsim.PortSignalSource.empty(  )
outputs slsim.PortSignalSource = slsim.PortSignalSource.empty(  )


inputSourceMap
outputSourceMap


inputFcns cell = cell( 0 )
outputFcns = [  ]
postStepFcn
simStatusChangeFcn
end 

properties ( Hidden )


postStepFcnDecimation( 1, 1 )double{ mustBePositive, mustBeInteger } = 1

end 

methods 
function obj = RuntimeFcnsInfo( model )

obj.modelName = model;

obj = obj.populateSources( 'Inport' );
obj = obj.populateSources( 'Outport' );
end 


function obj = addInputSource( obj, inputSrc )

obj.inputSourceMap( inputSrc.BlockPath.getBlock( 1 ) ) = numel( obj.inputs ) + 1;
obj.inputs( end  + 1 ) = inputSrc;
end 

function obj = addOutputSource( obj, outputSrc )

obj.outputSourceMap( outputSrc.BlockPath.getBlock( 1 ) ) = numel( obj.outputs ) + 1;
obj.outputs( end  + 1 ) = outputSrc;
end 


function obj = populateSources( obj, blockType )
blocks = find_system( obj.modelName, 'SearchDepth', 1, 'BlockType', blockType );
nSrcs = numel( blocks );

for idx = 1:nSrcs
paths = blocks{ idx };
portName = get_param( paths, 'PortName' );
src = slsim.PortSignalSource( BlockPath = Simulink.SimulationData.BlockPath( paths ),  ...
UserData = [  ],  ...
BusElement = '',  ...
PortName = portName,  ...
Element = '',  ...
Port = get_param( paths, 'Port' ) );
switch blockType
case 'Inport'
obj = obj.addInputSource( src );
case 'Outport'
obj = obj.addOutputSource( src );
end 
end 

end 

function [ idx, src ] = getSrcAndIdx( obj, fcn, srcMap, srcs )
idx =  - 1;
src = [  ];
idUsed = '';


if isfield( fcn.Data, 'BlockPath' )
idx = srcMap( fcn.Data.BlockPath.getBlock( 1 ) );
idUsed = fcn.Data.BlockPath.getBlock( 1 );
elseif isfield( fcn.Data, 'PortName' )
idx = srcMap( [ obj.modelName, '/', fcn.Data.PortName ] );
idUsed = fcn.Data.PortName;
elseif isfield( fcn.Data, 'Port' )
idx = str2num( fcn.Data.Port );%#ok<ST2NM>
idUsed = fcn.Data.Port;
end 

if idx ==  - 1
return ;
end 


src = srcs( idx );


dataFieldNames = fieldnames( fcn.Data );
for fieldIdx = 1:numel( dataFieldNames )
fieldName = dataFieldNames{ fieldIdx };

if strcmp( fieldName, 'UserData' )
continue ;
end 
if ~isequal( fcn.Data.( fieldName ), srcs( idx ).( fieldName ) )
msgId = 'SimulinkExecution:SimulationService:InvalidPortSpecification';
me = MException( msgId, message( msgId, idUsed ).getString(  ) );
throwAsCaller( me );
end 
end 

if isfield( fcn.Data, 'UserData' )
src.UserData = fcn.Data.UserData;
end 

end 

function obj = addInputFcn( obj, fcn )
[ idx, src ] = getSrcAndIdx( obj, fcn, obj.inputSourceMap, obj.inputs );
if idx ==  - 1
msgId = 'SimulinkExecution:SimulationService:InportNotFound';
me = MException( msgId, message( msgId ).getString(  ) );
throwAsCaller( me );
end 

if ~isempty( obj.inputFcns ) && numel( obj.inputFcns ) >= idx && ~isempty( obj.inputFcns{ idx } )
msgId = 'SimulinkExecution:SimulationService:DuplicateCallbackSpecified';
me = MException( msgId, message( msgId, idx ).getString(  ) );
throwAsCaller( me );
end 

obj.inputFcns{ idx } = @( time )fcn.Fcn( src, time );
end 

function obj = addOutputFcn( obj, fcn )
[ idx, src ] = getSrcAndIdx( obj, fcn, obj.outputSourceMap, obj.outputs );
if idx ==  - 1
msgId = 'SimulinkExecution:SimulationService:OutportNotFound';
me = MException( msgId, message( msgId ).getString(  ) );
throwAsCaller( me );
end 
if isempty( obj.outputFcns )
obj.outputFcns = struct( 'idx', int32( idx ),  ...
'fcn', @( time, data )fcn.Fcn( src, time, data ) );
else 
obj.outputFcns( end  + 1 ) = struct( 'idx', int32( idx ),  ...
'fcn', @( time, data )fcn.Fcn( src, time, data ) );
end 
end 

function obj = setFcns( obj, runtimeFcns )
R36
obj
runtimeFcns slsim.RuntimeFcns
end 
if isempty( runtimeFcns )
return ;
end 
for idx = 1:numel( runtimeFcns.InputFcns )
obj = obj.addInputFcn( runtimeFcns.InputFcns( idx ) );
end 

for idx = 1:numel( runtimeFcns.OutputFcns )
obj = obj.addOutputFcn( runtimeFcns.OutputFcns( idx ) );
end 

obj.postStepFcn = runtimeFcns.PostStepFcn;
obj.simStatusChangeFcn = runtimeFcns.SimStatusChangeFcn;

obj.postStepFcnDecimation = runtimeFcns.PostStepFcnDecimation;

if obj.postStepFcnDecimation ~= 1

if ( ~Simulink.isRaccelDeployed &&  ...
~isequal( get_param( obj.modelName, 'SimulationMode' ), 'rapid-accelerator' ) )
error( message( 'simulinkcompiler:runtime:PostStepFcnDecimationNotSupported',  ...
get_param( obj.modelName, 'SimulationMode' ) ) );
end 
end 

end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppvwmtS.p.
% Please follow local copyright laws when handling this file.

