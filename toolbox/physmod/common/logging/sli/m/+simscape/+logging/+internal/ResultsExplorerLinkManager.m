classdef ( Sealed )ResultsExplorerLinkManager < handle





properties 
LinkedInstance
end 

events 
LinkedInstanceChanged
end 

methods ( Access = private )
function obj = ResultsExplorerLinkManager(  )
end 
end 

methods ( Static, Access = ?hResultsExplorerLinkManagerTester )
function obj = manager(  )
import simscape.logging.internal.ResultsExplorerLinkManager
mlock(  );
persistent Manager
if isempty( Manager )
Manager = ResultsExplorerLinkManager(  );
end 
obj = Manager;
end 
end 

methods ( Static )

function link( obj )
R36
obj( 1, 1 )simscape.logging.internal.ResultsExplorerController
end 
import simscape.logging.internal.ResultsExplorerLinkManager
mng = ResultsExplorerLinkManager.manager(  );
if ~isequal( mng.LinkedInstance, obj )
mng.LinkedInstance = obj;
notify( mng, 'LinkedInstanceChanged' );
end 
end 



function unlink( obj )
R36
obj( 1, 1 )simscape.logging.internal.ResultsExplorerController
end 
import simscape.logging.internal.ResultsExplorerLinkManager
mng = ResultsExplorerLinkManager.manager(  );
if isequal( mng.LinkedInstance, obj )
mng.LinkedInstance = [  ];
notify( mng, 'LinkedInstanceChanged' );
end 
end 

function out = linkedInstance(  )
import simscape.logging.internal.ResultsExplorerLinkManager
mng = ResultsExplorerLinkManager.manager(  );
out = mng.LinkedInstance;
end 

function l = linkListener( callback )
import simscape.logging.internal.ResultsExplorerLinkManager
mng = ResultsExplorerLinkManager.manager(  );
l = event.listener( mng, 'LinkedInstanceChanged', callback );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpdFbaBu.p.
% Please follow local copyright laws when handling this file.

