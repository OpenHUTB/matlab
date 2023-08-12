classdef SubsystemInlinedBehavior < systemcomposer.internal.validator.BaseComponentBlockType


methods 

function this = SubsystemInlinedBehavior( handleOrPath )
R36
handleOrPath
end 
this.handleOrPath = handleOrPath;
end 

function [ canConvert, allowed ] = canAddVariant( this )
canConvert = true;
allowed = true;
end 

function [ canConvert, allowed ] = canInline( this )
canConvert = true;
allowed = true;
end 

function [ canConvert, allowed ] = canConjugatePort( ~ )
canConvert = true;
allowed = true;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7g6ir3.p.
% Please follow local copyright laws when handling this file.

