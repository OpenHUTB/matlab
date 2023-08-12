classdef BasePort < systemcomposer.arch.Element & systemcomposer.base.BasePort



properties 
Name
end 
properties ( SetAccess = private )
Direction
InterfaceName
Interface
Connectors
Connected
end 

methods ( Static )
function port = current( portHdl )
persistent pH
if nargin == 1
pH = portHdl;
end 
port = systemcomposer.arch.ComponentPort.empty(  );
if ishandle( pH )
portImpl = systemcomposer.utils.getArchitecturePeer( pH );
if ~isempty( portImpl )
port = systemcomposer.internal.getWrapperForImpl( portImpl );
end 
end 
end 
end 

methods 
function this = BasePort( archElemImpl )
this@systemcomposer.arch.Element( archElemImpl );
archElemImpl.cachedWrapper = this;

end 

function name = get.Name( this )
name = this.ElementImpl.getName;
end 

function set.Name( this, newName )
this.setName( newName );
end 

function direction = get.Direction( this )
if ( this.ElementImpl.getPortAction == systemcomposer.internal.arch.PHYSICAL )
direction = systemcomposer.arch.PortDirection.Physical;
elseif ( this.ElementImpl.getPortAction == systemcomposer.internal.arch.PROVIDE )
direction = systemcomposer.arch.PortDirection.Output;
elseif ( this.ElementImpl.getPortAction == systemcomposer.architecture.model.core.PortAction.SERVER )
direction = systemcomposer.arch.PortDirection.Server;
elseif ( this.ElementImpl.getPortAction == systemcomposer.internal.arch.REQUEST )
direction = systemcomposer.arch.PortDirection.Input;
else 
assert( this.ElementImpl.getPortAction == systemcomposer.architecture.model.core.PortAction.CLIENT );
direction = systemcomposer.arch.PortDirection.Client;
end 
end 

function conn = get.Connectors( this )
portImpl = this.getImpl;
connImpl = portImpl.getConnectors( this.getImpl.isRedefined );
conn = systemcomposer.arch.Connector.empty( 0, 0 );
for i = 1:numel( connImpl )
conn = [ conn, systemcomposer.internal.getWrapperForImpl( connImpl( i ) ) ];%#ok<AGROW>
end 
end 

function isConn = get.Connected( this )
isConn = ~isempty( this.Connectors );
end 

function intfName = get.InterfaceName( this )
intf = this.getImpl.getPortInterface;
if ~isempty( intf )
intfName = intf.getName;
else 
intfName = '';
end 
end 

function interface = get.Interface( this )
interfaceImpl = this.getImpl(  ).getPortInterface(  );
if ( ~isempty( interfaceImpl ) )
interface = systemcomposer.internal.getWrapperForImpl( interfaceImpl );
else 
if this.Direction == systemcomposer.arch.PortDirection.Physical
interface = systemcomposer.interface.PhysicalInterface.empty(  );
else 
interface = systemcomposer.interface.DataInterface.empty(  );
end 
end 
end 

function conn = getConnectorTo( this, otherPort )


R36
this systemcomposer.arch.BasePort
otherPort systemcomposer.arch.BasePort
end 
conn = systemcomposer.arch.Connector.empty;
thisImpl = this.getImpl(  );
otherImpl = otherPort.getImpl(  );
includeRedefinedConnectors = true;
connImpl = thisImpl.getConnectorTo( otherImpl, includeRedefinedConnectors );
if ~isempty( connImpl )
conn = systemcomposer.internal.getWrapperForImpl( connImpl );
end 
end 
end 

methods 
applyStereotype( this, stereotype );
end 

methods ( Access = protected )
portHandle = getPortHandleForConnection( this, elem );
end 

methods ( Access = protected, Abstract )
archObj = getArchitectureScopeForConnectors( this );
end 

methods ( Hidden = true )
cn = connectHelper( this, other, parArch, stereotype, shouldFlush, varargin );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcww1ag.p.
% Please follow local copyright laws when handling this file.

