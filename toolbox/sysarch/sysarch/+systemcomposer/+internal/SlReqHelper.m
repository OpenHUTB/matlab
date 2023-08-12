classdef SlReqHelper < handle & matlab.mixin.SetGet





properties ( Dependent, SetAccess = private )
ReqSet;
Domain;
Summary;
Id;
end 

properties ( Hidden )
Impl;
end 

methods 
function obj = SlReqHelper( rmiStruct )

obj.Impl = rmiStruct;
end 

function reqSet = get.ReqSet( obj )
reqSet = obj.Impl.reqSet;
end 

function domain = get.Domain( obj )
domain = obj.Impl.domain;
end 

function summary = get.Summary( obj )
summary = obj.Impl.summary;
end 

function id = get.Id( obj )
if isempty( obj.Impl.id )

id = num2str( obj.Impl.sid );
else 
id = obj.Impl.id;
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpjGK0rQ.p.
% Please follow local copyright laws when handling this file.

