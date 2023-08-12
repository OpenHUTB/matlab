function cn = connectHelper( this, otherPort, parArch, stereotype, nameValArgs )




R36
this
otherPort
parArch
stereotype{ mustBeTextScalar } = ""
nameValArgs.ShouldFlush logical = true
nameValArgs.SourceElement{ mustBeTextScalar } = ""
nameValArgs.DestinationElement{ mustBeTextScalar } = ""
nameValArgs.Routing{ mustBeRoutingOption } = "smart"
end 

stereotype = char( stereotype );
shouldFlush = nameValArgs.ShouldFlush;
srcElement = char( nameValArgs.SourceElement );
dstElement = char( nameValArgs.DestinationElement );
routingOption = char( nameValArgs.Routing );

checkOtherPortElementNotConnected( otherPort, srcElement, dstElement )

cn = systemcomposer.arch.Connector.empty(  );


if ~this.getImpl.canConnect( otherPort.getImpl )
msgObj = message( 'SystemArchitecture:Architecture:ConnectorStereotypeMismatch' );
throw( MException( msgObj.Identifier, msgObj.getString ) );
end 

try 
systemName = parArch.getQualifiedName;
srcPortHandle = this.getPortHandleForConnection( srcElement );
if ~isempty( srcElement )
set_param( srcPortHandle, 'Element', srcElement );
end 
srcPort = getPortExprFromHandle( srcPortHandle );

if isa( otherPort, 'systemcomposer.arch.ArchitecturePort' )
for i = 1:numel( otherPort.Connectors )
if any( cellfun( @( x )isequal( dstElement, x ), otherPort.Connectors( i ).getDestinationElement ) )
msgObj = message( 'SystemArchitecture:API:DuplicateDestinationElementOnConnectionError', dstElement,  ...
otherPort.Connectors( i ).SourcePort.Name, otherPort.Connectors( i ).SourcePort.Parent.Name );
throw( MException( msgObj.Identifier, msgObj.getString ) );
end 
end 



dstPortHandle = otherPort.getPortHandleForConnection( dstElement );
if ~isempty( dstElement )
set_param( dstPortHandle, 'Element', dstElement );
end 
dstPort = getPortExprFromHandle( dstPortHandle );
else 
dstPortHandle = otherPort.getPortHandleForConnection(  );
dstPort = getPortExprFromHandle( dstPortHandle );
end 

if strcmpi( get_param( srcPortHandle, 'type' ), 'port' )
lineHdl = get_param( srcPortHandle, 'Line' );
if ~isequal( lineHdl,  - 1 ) && ~this.Connected && isequal( get_param( lineHdl, 'DstPortHandle' ),  - 1 )
delete_line( lineHdl );
if ( shouldFlush )
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( systemName ) );
end 
end 
end 


if strcmpi( get_param( dstPortHandle, 'type' ), 'port' )
lineHdl = get_param( dstPortHandle, 'Line' );
if ~isequal( lineHdl,  - 1 ) && ~otherPort.Connected && isequal( get_param( lineHdl, 'SrcPortHandle' ),  - 1 )
delete_line( lineHdl );
if ( shouldFlush )
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( systemName ) );
end 
end 
end 


add_line( systemName, srcPort, dstPort, 'autorouting', routingOption );

if ( shouldFlush )
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( systemName ) );
end 
dstC = otherPort.Connectors;
for k = 1:length( dstC )
if otherPort.Direction == systemcomposer.arch.PortDirection.Physical




ports = dstC( k ).Ports;
for idx = 1:length( ports )
port = ports( idx );
if port == this
cn = dstC( k );
break ;
end 
end 
if ~isempty( cn )
break ;
end 
else 

if dstC( k ).SourcePort == this
cn = dstC( k );
break ;
end 
end 
end 
if ~isempty( stereotype ) && ~isempty( cn )
systemcomposer.internal.arch.applyPrototype( cn.getImpl, stereotype );
end 

catch ex
msgObj = message( 'SystemArchitecture:API:PortConnectionError', ex.message );
exception = MException( 'systemcomposer:API:PortConnectionError', msgObj.getString );
throw( exception );
end 

end 


function expr = getPortExprFromHandle( ph )





expr = '';
phType = get_param( ph, 'Type' );

if strcmpi( phType, 'port' )

blk = get_param( ph, 'Parent' );
hdlStruct = get_param( blk, 'PortHandles' );
name = get_param( blk, 'Name' );
name = strrep( name, '/', '//' );

switch get_param( ph, 'PortType' )
case 'connection'

hdls = hdlStruct.LConn;
idx = find( hdls == ph );
if ~isempty( idx )
expr = [ name, '/LConn', num2str( idx ) ];
else 
hdls = hdlStruct.RConn;
idx = find( hdls == ph );
if ~isempty( idx )
expr = [ name, '/RConn', num2str( idx ) ];
end 
end 
case { 'outport', 'inport' }
pn = get_param( ph, 'PortNumber' );
expr = [ name, '/', num2str( pn ) ];
otherwise 
assert( false );
end 

else 
assert( strcmpi( phType, 'block' ) );
bType = get_param( ph, 'BlockType' );
name = get_param( ph, 'Name' );
name = strrep( name, '/', '//' );
switch lower( bType )
case { 'inport', 'outport' }
expr = [ name, '/1' ];
case 'pmioport'
expr = [ name, '/RConn1' ];
end 
end 

end 


function mustBeRoutingOption( arg )

if ~any( arg == [ "on", "off", "smart" ] )
msgObj = message( 'SystemArchitecture:API:InvalidRoutingOption' );
exception = MException( 'systemcomposer:API:InvalidRoutingOption', msgObj.getString );
throw( exception );
end 

end 


function checkOtherPortElementNotConnected( otherPort, srcElement, dstElement )

if otherPort.Connected && isempty( srcElement ) && isempty( dstElement )
if ( otherPort.Direction ~= systemcomposer.arch.PortDirection.Physical &&  ...
isempty( otherPort.getImpl.getConnectors.p_Redefines ) )

msgObj = message( 'SystemArchitecture:API:PortConnected' );
exception = MException( 'systemcomposer:API:PortConnected', msgObj.getString );
throw( exception );
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpAd9vEW.p.
% Please follow local copyright laws when handling this file.

