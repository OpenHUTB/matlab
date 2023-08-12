classdef CleanUpRules < handle

properties 
keep( 1, : )string;
remove( 1, : )string;
conditions( 1, : );
end 

methods 
function obj = CleanUpRules( options )
R36
options.keep( 1, : )string;
options.remove( 1, : )string
options.conditions( 1, : );
end 
if isfield( options, 'keep' )
obj.keep = options.keep;
end 
if isfield( options, 'remove' )
obj.remove = options.remove;
end 
if isfield( options, 'conditions' )
obj.conditions = options.conditions;
end 
end 

function [ keep, remove ] = applyRules( obj, option )
R36
obj;
option;
end 
keep = obj.keep;
remove = obj.remove;
end 
end 
end 

function mustNotIntersect( arg1, arg2 )
if ismember( arg1, arg2 )
eidType = 'classdiagram:editor:resources:MustNotIntersect';
msgType = message( eidType );
throwAsCaller( MException( eidType, msgType ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpkWFMlJ.p.
% Please follow local copyright laws when handling this file.

