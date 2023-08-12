






















classdef SimulinkPortSpecification < handle

properties 





InputArguments( 1, : )Simulink.CustomCode.FunctionArgument






ReturnArgument( 1, : )Simulink.CustomCode.FunctionArgument






GlobalArguments( 1, : )Simulink.CustomCode.FunctionArgument
end 


methods 
function obj = SimulinkPortSpecification( functionPortSpecification )
if nargin < 1
return ;
end 

obj.InputArguments = functionPortSpecification.InputArguments;
obj.ReturnArgument = functionPortSpecification.ReturnArgument;
obj.GlobalArguments = functionPortSpecification.GlobalArguments;
end 

function ret = getGlobalArg( obj, argName )
R36
obj( 1, 1 )Simulink.CodeImporter.SimulinkPortSpecification
argName( 1, : ){ validateattributes( argName, { 'char', 'string' }, { 'scalartext' } ) } = ''
end 

globalArgs = obj.GlobalArguments;
idx = ismember( { globalArgs.Name }, argName );
ret = globalArgs( idx );
assert( numel( ret ) <= 1 );
if isempty( ret )
errmsg = MException( message( 'Simulink:CustomCode:NonexistentGlobalArgument', argName ) );
throw( errmsg );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmprnspyp.p.
% Please follow local copyright laws when handling this file.

