classdef ( Sealed )HistorySize < matlab.internal.profiler.types.MatlabConfigOption




properties ( SetAccess = immutable )
SizeOfHistory
end 

methods 
function obj = HistorySize( size )
R36
size( 1, 1 ){ mustBePositive, mustBeInteger }
end 

obj.SizeOfHistory = size;
end 
end 

methods ( Static )
function out = isTypeOf( option )
out = isa( option, 'matlab.internal.profiler.types.HistorySize' );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDylwp7.p.
% Please follow local copyright laws when handling this file.

