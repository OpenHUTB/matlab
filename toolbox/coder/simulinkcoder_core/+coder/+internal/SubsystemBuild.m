classdef SubsystemBuild < handle





properties ( Access = private )
SourceSubsystemName
NewModelName
OrigBlockHdl
GenModelHdl
end 

methods ( Static, Access = private )


function out = getSetInstance( in )
persistent instance

if nargin == 1
instance = in;
else 
if isempty( instance )
instance = coder.internal.SubsystemBuild( '', '' );
end 
out = instance;
end 

end 
end 

methods ( Static )

function val = getSourceSubsysName
obj = coder.internal.SubsystemBuild.getSetInstance;
val = obj.SourceSubsystemName;
end 

function val = getNewModelName
obj = coder.internal.SubsystemBuild.getSetInstance;
val = obj.NewModelName;
end 

function val = getOrigBlockHdl
obj = coder.internal.SubsystemBuild.getSetInstance;
val = obj.OrigBlockHdl;
end 


function val = getGenModelHdl
obj = coder.internal.SubsystemBuild.getSetInstance;
val = obj.GenModelHdl;
end 


function cleanupFcn = create( varargin )
obj = coder.internal.SubsystemBuild( varargin{ : } );
obj.getSetInstance( obj );
if nargout == 1
cleanupFcn = onCleanup( @(  )coder.internal.SubsystemBuild.reset );
end 
end 

function reset
coder.internal.SubsystemBuild.getSetInstance( [  ] );
end 

end 

methods ( Access = private )

function this = SubsystemBuild( origBlockHdl, genModelHdl )

if ~isempty( origBlockHdl )
this.SourceSubsystemName = getfullname( origBlockHdl );
this.NewModelName = get_param( genModelHdl, 'Name' );
else 
this.SourceSubsystemName = '';
this.NewModelName = '';
end 
this.OrigBlockHdl = origBlockHdl;
this.GenModelHdl = genModelHdl;
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYxHwQu.p.
% Please follow local copyright laws when handling this file.

