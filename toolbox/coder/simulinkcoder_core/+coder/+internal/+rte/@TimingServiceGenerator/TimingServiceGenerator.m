classdef TimingServiceGenerator < handle





properties ( Constant )
TimerDataName = 'RTE_TimerService_private';
InternalTickFcnName = '__tick';
InternalTime0FcnName = '__time_0';
end 

properties ( Access = private )
PluginContext( 1, 1 )coder.internal.rte.PluginContext
RTEImplementationFilename( 1, : )char
RTEPrivateHeaderFilename( 1, : )char
RTEOutFolder( 1, : )char
RTEUtil = coder.internal.rte.util;
end 

methods 
function this = TimingServiceGenerator(  ...
pluginContext, implementationFilename, privateHeaderFilename, outFolder )
R36
pluginContext( 1, 1 )coder.internal.rte.PluginContext
implementationFilename( 1, : )char
privateHeaderFilename( 1, : )char
outFolder( 1, : )char
end 
this.PluginContext = pluginContext;
this.RTEImplementationFilename = implementationFilename;
this.RTEPrivateHeaderFilename = privateHeaderFilename;
this.RTEOutFolder = outFolder;
end 
end 

methods ( Access = private )


generateImplemenationForSIL( this, model, platformServices, writer )

generatePrivateInterfaceForSIL( this, model, info )

info = collectTimerServiceInfoForSIL( this, platformServices )


generateImplemenationForNativeApplication( this, model, platformServices, writer )

generatePrivateInterfaceForNativeApplication( this, model, info )

info = collectTimerServiceInfoForNativeApplication( this, platformServices )


function fcn = constructGetImpl( this, service )
storageClass = 'extern';
returnType = service.Data.Type;
fcnName = service.Name;

argList = [  ];
fcnBody = { [ 'return ', this.TimerDataName, '.', service.Data.Name, ';' ] };
fcn = coder.internal.rteproxy.FunctionWriter( storageClass, returnType, fcnName, argList, fcnBody );
end 

function fcn = constructSetImpl( this, service )
storageClass = 'extern';
returnType = 'void';
fcnName = [ 'set_', service.Name ];
argList = { [ service.Data.Type, ' v' ] };
fcnBody = { [ this.TimerDataName, '.', service.Data.Name, ' = v;' ] };
fcn = coder.internal.rteproxy.FunctionWriter( storageClass, returnType, fcnName, argList, fcnBody );
end 

function fcn = constructGetPtrImpl( this, service )
storageClass = 'extern';
returnType = [ service.Data.Type, '*' ];
fcnName = [ service.Name, '_ptr' ];
argList = [  ];
fcnBody = { [ 'return &(', this.TimerDataName, '.', service.Data.Name, ');' ] };
fcn = coder.internal.rteproxy.FunctionWriter( storageClass, returnType, fcnName, argList, fcnBody );
end 

function fcn = constructPreStepFcnForSIL( this, preStepInfo, tid, resolution )
storageClass = 'extern';
returnType = 'void';
fcnName = [ 'pre_step_', num2str( tid ), '_timer' ];
argList = [  ];
needCacheTime = false;
time0Str = [ '*(', this.InternalTime0FcnName, '_ptr())' ];
resStr = num2str( resolution );
fcnBody = [  ];
for serviceIdx = 1:length( preStepInfo )
if preStepInfo{ serviceIdx }.needPrevTime
needCacheTime = true;
end 

switch preStepInfo{ serviceIdx }.ServiceType
case coder.descriptor.TimerServiceType.AbsoluteTime
fcnBody = [ fcnBody, { [ preStepInfo{ serviceIdx }.PrivateSetFcn.FunctionName, '(', time0Str, ');' ] } ];%#ok
case coder.descriptor.TimerServiceType.FunctionClockTick
fcnBody = [ fcnBody, { [ preStepInfo{ serviceIdx }.PrivateSetFcn.FunctionName, '(floor((', time0Str, ')/', resStr, ' + 0.5));' ] } ];%#ok
case coder.descriptor.TimerServiceType.FunctionStepSize
fcnBody = [ fcnBody, { [ preStepInfo{ serviceIdx }.PrivateSetFcn.FunctionName, '(', time0Str, ' - prevTime);' ] } ];%#ok
case coder.descriptor.TimerServiceType.FunctionStepTick
fcnBody = [ fcnBody, { [ preStepInfo{ serviceIdx }.PrivateSetFcn.FunctionName, '(floor((', time0Str, ' - prevTime)/', resStr, ' + 0.5));' ] } ];%#ok
end 
end 

if needCacheTime
fcnBody = [ { 'static real_T prevTime = 0;' }, fcnBody, { [ 'prevTime = ', time0Str, ';' ] } ];
end 
fcn = coder.internal.rteproxy.FunctionWriter( storageClass, returnType, fcnName, argList, fcnBody );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpUa3W8E.p.
% Please follow local copyright laws when handling this file.

