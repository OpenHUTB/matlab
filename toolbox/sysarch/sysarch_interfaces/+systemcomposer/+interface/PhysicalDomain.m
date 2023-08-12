classdef PhysicalDomain < systemcomposer.base.BaseElement












































properties ( Dependent )

Domain
end 

properties ( Dependent, SetAccess = private )

Owner
end 
properties ( Dependent = true, SetAccess = private )

Model
end 

methods 
function obj = PhysicalDomain( implObj )
R36
implObj systemcomposer.architecture.model.interface.AtomicPhysicalInterface
end 

obj@systemcomposer.base.BaseElement( implObj );
domainStr = strtrim( strrep( implObj.p_Type, 'Connection:', '' ) );
obj.Domain = domainStr;
implObj.cachedWrapper = obj;
end 

function mdl = get.Model( this )
mdl = this.Owner.Model;
end 

function set.Domain( this, val )
domain = systemcomposer.interface.PhysicalDomain.resolveDomain( val );




owner = this.getOwner(  );
if ~isempty( owner )
if isa( owner, 'systemcomposer.arch.ArchitecturePort' )

systemcomposer.AnonymousInterfaceManager.SetSLPortProperty(  ...
this.getOwner(  ).SimulinkHandle, 'Type', domain );
elseif isa( owner, 'systemcomposer.interface.PhysicalElement' )

owner.Type = domain;
end 
end 
end 

function val = get.Domain( this )
val = this.getImpl(  ).p_Type;
val = strtrim( strrep( val, 'Connection: ', '' ) );
end 

function owner = get.Owner( this )
owner = this.getOwner(  );
end 

function destroy( ~ )

end 
end 

methods ( Hidden )
function setType( this, val )

this.Domain = val;
end 
end 

methods ( Hidden, Static )
function resolvedDomain = resolveDomain( domainStr )
R36
domainStr{ mustBeTextScalar }
end 

availDomains = string( simscape.internal.availableDomains(  ) );


if strlength( domainStr ) == 0 || strcmp( domainStr, '<domain name>' )
resolvedDomain = '';
return ;
end 



idx = strcmp( availDomains, domainStr );
if any( idx )
match = availDomains( idx );
else 
idx = availDomains.contains( domainStr );
match = availDomains( idx );
end 
if length( match ) == 1
resolvedDomain = char( match );
else 

if length( match ) > 1


matchStr = "";
for idx = 1:length( match )
matchStr = matchStr + sprintf( "\n\t'%s'", match( idx ) );
end 
error( message( 'SystemArchitecture:API:AmbiguousPhysicalDomainName', domainStr, matchStr ) );
else 

error( message( 'SystemArchitecture:API:InvalidPhysicalDomainName', domainStr ) );
end 
end 
end 
end 

methods ( Access = private )
function owner = getOwner( this )



owner = [  ];
implObj = this.getImpl(  );
if ~isempty( implObj.p_AnonymousUsage )
ownerImpl = implObj.p_AnonymousUsage.p_Port;
owner = systemcomposer.internal.getWrapperForImpl( ownerImpl );
elseif ~isempty( implObj.p_PhysicalElement )
ownerImpl = implObj.p_PhysicalElement;
owner = systemcomposer.internal.getWrapperForImpl( ownerImpl );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmusdQI.p.
% Please follow local copyright laws when handling this file.

