classdef SubsystemReferenceUninitialized < systemcomposer.internal.validator.BaseComponentBlockType


methods 

function this = SubsystemReferenceUninitialized( handleOrPath )
R36
handleOrPath
end 
this.handleOrPath = handleOrPath;
end 

function [ canConvert, allowed ] = canLinkToModel( this )
canConvert = true;
allowed = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpD27bVm.p.
% Please follow local copyright laws when handling this file.

