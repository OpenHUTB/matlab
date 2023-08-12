classdef MATLABCoderToolchainListFilter < coder.make.internal.ToolchainListFilter







properties ( Access = private )
IsGPUCoder
end 

methods 
function obj = MATLABCoderToolchainListFilter( isGpuCoder, prodHWDeviceType, targetHWDeviceType, prodEqTarget )

R36
isGpuCoder( 1, 1 )logical
prodHWDeviceType( 1, : )char
targetHWDeviceType( 1, : )char
prodEqTarget( 1, 1 )logical
end 


obj.IsGPUCoder = isGpuCoder;
if prodEqTarget
obj = obj.setTargetHWDeviceType( prodHWDeviceType );
else 
obj = obj.setTargetHWDeviceType( targetHWDeviceType );
end 
end 

function ret = isProductConfigurationCompatible( obj, toolchainInfoRegistry )
R36
obj
toolchainInfoRegistry( 1, 1 )coder.make.internal.IToolchainInfoRegistry
end 



tcName = toolchainInfoRegistry.Name;
if contains( tcName, 'AUTOSAR Adaptive' )
ret = false;
return ;
end 

isGPUToolchain = contains( tcName, 'NVIDIA' ) &&  ...
~strcmpi( tcName, 'GNU GCC for NVIDIA Embedded Processors' );

ret = obj.IsGPUCoder == isGPUToolchain;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpzrD78k.p.
% Please follow local copyright laws when handling this file.

