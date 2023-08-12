classdef ( Sealed )Stereotype < systemcomposer.profile.internal.Element















































































properties ( Transient, Dependent )



Name;



Description











Parent;












AppliesTo( 1, 1 )string{ mustBeMetaclassString };




Abstract logical;























Icon










ComponentHeaderColor( 1, 3 )uint32










ConnectorLineColor( 1, 3 )uint32












ConnectorLineStyle;
end 

properties ( Transient, Dependent, Hidden )

















Color;
end 

properties ( Transient, Dependent, SetAccess = private )



FullyQualifiedName;


Profile;






OwnedProperties;





Properties;
end 

methods ( Static )
function stereotype = find( name )






R36
name char
end 

[ isFQN, pre, suf ] = systemcomposer.profile.Stereotype.isFQN( name );
if ~isFQN
error( message( 'SystemArchitecture:Profile:InputArgMustBeFQN' ) );
end 


profile = systemcomposer.profile.Profile.find( pre );
if isempty( profile )
stereotype = systemcomposer.profile.Stereotype.empty(  );
else 


try 
stereotype = profile.getStereotype( suf );
catch me
if strcmp( me.identifier, 'SystemArchitecture:Profile:CouldNotFindStereotypeInProfile' )
stereotype = systemcomposer.profile.Stereotype.empty(  );
else 
throw( me );
end 
end 
end 
end 
end 





methods 
function property = addProperty( this, propName, varargin )














txn = this.Model.beginTransaction;
pImpl = this.Impl.addProperty( propName );
txn.commit;
property = systemcomposer.profile.Property.wrapper( pImpl );
property.applyNameValuePairs( varargin{ : } );
end 

function removeProperty( this, propNameOrObj )







if ischar( propNameOrObj ) || ( isstring( propNameOrObj ) && isscalar( propNameOrObj ) )

prop = this.findProperty( propNameOrObj );
elseif isa( propNameOrObj, 'systemcomposer.profile.Property' )

prop = propNameOrObj;
else 
error( message( 'SystemArchitecture:Profile:InputArgPropNameOrObj' ) );
end 



if ~isequal( prop.Stereotype, this )
error( message( 'SystemArchitecture:Profile:CannotRemoveUnownedProperty',  ...
prop.Name, prop.Stereotype.Name ) );
end 
txn = this.Model.beginTransaction;
prop.destroy(  );
txn.commit;
end 

function property = findProperty( this, propName )



props = this.Properties;
idx = arrayfun( @( x )strcmp( x.Name, propName ), props );
if ~any( idx )
property = systemcomposer.profile.Property.empty(  );
else 
property = props( idx );
end 
end 

function destroy( this )




txn = this.Model.beginTransaction;
this.Impl.destroy(  );
txn.commit;
end 

function setDefaultElementStereotype( this, metaClassStr, otherStereoNameOrObj )

































R36
this systemcomposer.profile.Stereotype
metaClassStr string{ mustBeMetaclassString }
otherStereoNameOrObj
end 

metaClassStr = char( metaClassStr );
otherStereo = systemcomposer.profile.Stereotype.empty;

if ~isempty( otherStereoNameOrObj )

if ischar( otherStereoNameOrObj ) || ( isstring( otherStereoNameOrObj ) && isscalar( otherStereoNameOrObj ) )


if ~systemcomposer.profile.Stereotype.isFQN( char( otherStereoNameOrObj ) )
otherStereoNameOrObj = string( this.Profile.Name ) + "." + otherStereoNameOrObj;
end 
otherStereo = systemcomposer.profile.Stereotype.find( char( otherStereoNameOrObj ) );
elseif isa( otherStereoNameOrObj, 'systemcomposer.profile.Stereotype' )
otherStereo = otherStereoNameOrObj;
end 


if isempty( otherStereo )
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 


if otherStereo.Profile ~= this.Profile
error( message( 'SystemArchitecture:Profile:NoCrossProfileDefaults' ) );
end 

end 





warningRestorer = this.disableDefaultStereotypeAPIDeprecationWarning(  );
switch metaClassStr
case 'Component'
this.setDefaultComponentStereotype( otherStereo );
case 'Port'
this.setDefaultPortStereotype( otherStereo );
case 'Connector'
this.setDefaultConnectorStereotype( otherStereo );
case 'Interface'


error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
case 'Function'
this.setDefaultFunctionStereotype( otherStereo );
end 
delete( warningRestorer );
end 

function stereo = getDefaultElementStereotype( this, metaClassStr )

















R36
this systemcomposer.profile.Stereotype
metaClassStr string{ mustBeMetaclassString }
end 





warningRestorer = this.disableDefaultStereotypeAPIDeprecationWarning(  );
switch metaClassStr
case 'Component'
stereo = this.getDefaultComponentStereotype(  );
case 'Port'
stereo = this.getDefaultPortStereotype(  );
case 'Connector'
stereo = this.getDefaultConnectorStereotype(  );
case 'Interface'


error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
case 'Function'
stereo = this.getDefaultFunctionStereotype(  );
end 
delete( warningRestorer );
end 

function appliesTo = getExtendedElement( this )




appliesTo = this.getImpl.getExtendedElement;
end 

function tf = isDerivedFrom( this, otherStereotype )





if ischar( otherStereotype ) || ( isstring( otherStereotype ) && isscalar( otherStereotype ) )
otherStereotype = systemcomposer.profile.Stereotype.find( char( otherStereotype ) );
otherImpl = otherStereotype.getImpl(  );

elseif isa( otherStereotype, 'systemcomposer.profile.Stereotype' ) && isscalar( otherStereotype )
otherImpl = otherStereotype.getImpl(  );

else 
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 

thisImpl = this.getImpl(  );
tf = ( thisImpl == otherImpl ) || thisImpl.isParentPrototype( otherImpl );
end 





function set.Name( this, name )
txn = this.Model.beginTransaction;
this.Impl.setName( name );
txn.commit;
end 

function name = get.Name( this )
name = this.Impl.getName(  );
end 

function name = get.FullyQualifiedName( this )
name = this.Impl.fullyQualifiedName;
end 

function set.Description( this, desc )
txn = this.Model.beginTransaction;
this.Impl.description = desc;
txn.commit;
end 

function desc = get.Description( this )
desc = this.Impl.description;
end 

function set.Parent( this, stereotypeNameOrObj )
txn = this.Model.beginTransaction;
if ischar( stereotypeNameOrObj ) || ( isstring( stereotypeNameOrObj ) && numel( stereotypeNameOrObj ) == 1 )

obj = this.resolveStereotype( stereotypeNameOrObj );
if isempty( obj )
error( message( 'SystemArchitecture:Profile:CouldNotFindStereotype', stereotypeNameOrObj ) );
end 
this.Impl.parent = obj.Impl;

elseif isa( stereotypeNameOrObj, 'systemcomposer.profile.Stereotype' )

this.Impl.parent = stereotypeNameOrObj.Impl;

else 
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 
txn.commit;
end 

function parent = get.Parent( this )

if isempty( this.Impl.parent )
parent = systemcomposer.profile.Stereotype.empty(  );
else 
parent = systemcomposer.profile.Stereotype.wrapper( this.Impl.parent );
end 
end 

function set.AppliesTo( this, value )
txn = this.Model.beginTransaction;
value = char( value );
this.Impl.setAppliesTo( value );
txn.commit;
end 

function value = get.AppliesTo( this )
value = this.Impl.appliesTo.toArray;
if isempty( value ) && ~isempty( this.Impl.getExtendedElement )

value = DAStudio.message( 'SystemArchitecture:Profile:Inherited' );
elseif length( value ) == 1

value = value{ 1 };
end 
end 

function set.Icon( this, value )
txn = this.Model.beginTransaction;
if ~isempty( value )
iconVal = this.getIconValue( value );
if ( iconVal == systemcomposer.internal.profile.PrototypeIcon.CUSTOM )
this.Impl.setCustomIcon( value );
else 
this.Impl.icon = iconVal;
end 
else 

this.Impl.icon = systemcomposer.internal.profile.PrototypeIcon.empty( 0, 0 );
end 
txn.commit;
end 

function value = get.Icon( this )
value = '';
if ~isempty( this.Impl.icon )
if ( this.Impl.icon == systemcomposer.internal.profile.PrototypeIcon.CUSTOM )
path = this.Impl.getCustomIconPath;
[ ~, name, ext ] = fileparts( path );
value = [ name, ext ];
else 
value = this.getIconName( this.Impl.icon );
end 
end 
end 

function set.Color( this, value )
warning( message( 'SystemArchitecture:Profile:DeprecatedColorProperty' ) );
colorVal = systemcomposer.profile.internal.getRGBValueForGivenColorName( char( value ) );
this.ComponentHeaderColor = colorVal;
end 

function set.ComponentHeaderColor( this, value )
assert( isinteger( value ) );
txn = this.Model.beginTransaction;
this.Impl.setComponentHeaderColorInRGB( value );
txn.commit;
end 

function name = get.Color( this )
value = this.ComponentHeaderColor;
name = systemcomposer.profile.Stereotype.internal.getColorNameForGivenRGBValue( value );
end 

function value = get.ComponentHeaderColor( this )
value = transpose( this.Impl.getComponentHeaderColorInRGB );
value = value( 1:3 );
end 

function set.ConnectorLineColor( this, value )
txn = this.Model.beginTransaction;
this.Impl.setConnectorLineColorInRGB( value );
txn.commit;
end 

function value = get.ConnectorLineColor( this )
value = transpose( this.Impl.getConnectorLineColorInRGB );
value = value( 1:3 );
end 

function set.ConnectorLineStyle( this, value )
txn = this.Model.beginTransaction;
styleVal = this.getConnectorStyleValue( value );
txn.commit;
this.Impl.connectorLineStyle = styleVal;
end 

function value = get.ConnectorLineStyle( this )
value = this.getConnectorStyleName( this.Impl.connectorLineStyle );
end 

function value = get.Abstract( this )
value = this.Impl.abstract;
end 

function set.Abstract( this, value )
txn = this.Model.beginTransaction;
this.Impl.abstract = value;
txn.commit;
end 

function profile = get.Profile( this )
pImpl = this.Impl.profile;
profile = systemcomposer.profile.Profile.wrapper( pImpl );
end 

function cProps = get.OwnedProperties( this )

impls = this.Impl.propertySet.properties.toArray;
if isempty( impls )
cProps = systemcomposer.profile.Property.empty(  );
else 
cProps = arrayfun( @( x )systemcomposer.profile.Property.wrapper( x ), impls );
end 
end 

function props = get.Properties( this )
props = this.recursivelyGetProperties(  );
end 
end 





properties ( Transient, Constant, Access = private )
ImplClassName = 'systemcomposer.internal.profile.Prototype';

IconNames = {  ...
'default',  ...
'application',  ...
'channel',  ...
'controller',  ...
'database',  ...
'devicedriver',  ...
'memory',  ...
'network',  ...
'plant',  ...
'sensor',  ...
'subsystem',  ...
'transmitter' ...
 };

LineStyleNames = { 
'Default',  ...
'Dot',  ...
'Dash',  ...
'Dash Dot',  ...
'Dash Dot Dot'
 };

IconValues = [  ...
systemcomposer.internal.profile.PrototypeIcon.GENERIC,  ...
systemcomposer.internal.profile.PrototypeIcon.APPLICATION,  ...
systemcomposer.internal.profile.PrototypeIcon.CHANNEL,  ...
systemcomposer.internal.profile.PrototypeIcon.CONTROLLER,  ...
systemcomposer.internal.profile.PrototypeIcon.DATABASE,  ...
systemcomposer.internal.profile.PrototypeIcon.DEVICEDRIVER,  ...
systemcomposer.internal.profile.PrototypeIcon.MEMORY,  ...
systemcomposer.internal.profile.PrototypeIcon.NETWORK,  ...
systemcomposer.internal.profile.PrototypeIcon.PLANT,  ...
systemcomposer.internal.profile.PrototypeIcon.SENSOR,  ...
systemcomposer.internal.profile.PrototypeIcon.SUBSYSTEM,  ...
systemcomposer.internal.profile.PrototypeIcon.TRANSMITTER ...
 ];

LineStyleValues = [  ...
systemcomposer.internal.profile.ConnectorStyle.GENERIC,  ...
systemcomposer.internal.profile.ConnectorStyle.DOT,  ...
systemcomposer.internal.profile.ConnectorStyle.DASH,  ...
systemcomposer.internal.profile.ConnectorStyle.DASH_DOT,  ...
systemcomposer.internal.profile.ConnectorStyle.DASH_DOT_DOT
 ];
end 

methods ( Static, Access = { ?systemcomposer.profile.Profile, ?systemcomposer.profile.Property } )
function stereotype = wrapper( impl )



assert( isa( impl, systemcomposer.profile.Stereotype.ImplClassName ) );
if ~isempty( impl.cachedWrapper ) && isvalid( impl.cachedWrapper )
stereotype = impl.cachedWrapper;
else 
stereotype = systemcomposer.profile.Stereotype( impl );
end 
end 

function [ is, pre, suf ] = isFQN( name )


name = convertStringsToChars( name );
assert( ischar( name ) );
[ pre, suf ] = strtok( name, '.' );
if ~isempty( suf )
suf = suf( 2:end  );
end 
is = isvarname( pre ) && isvarname( suf );
end 
end 

methods ( Access = private )
function this = Stereotype( impl )



assert( isa( impl, systemcomposer.profile.Stereotype.ImplClassName ) );
this@systemcomposer.profile.internal.Element( impl );
end 

function obj = resolveStereotype( this, name )


obj = [  ];
if isa( name, 'systemcomposer.profile.Stereotype' )
obj = name;
return ;
end 
name = string( name );
if ( isstring( name ) && isscalar( name ) )
if ~systemcomposer.profile.Stereotype.isFQN( name )
name = string( this.Profile.Name ).append( "." ).append( name );
end 
obj = systemcomposer.profile.Stereotype.find( name );
end 
end 

function props = recursivelyGetProperties( this )



props = this.OwnedProperties;
if ~isempty( this.Parent )
inheritedProps = this.Parent.recursivelyGetProperties(  );
props = [ props, inheritedProps ];
end 
end 

function val = getIconValue( this, name )



idx = strcmpi( name, this.IconNames );
val = this.IconValues( idx );
if isempty( val )
val = systemcomposer.internal.profile.PrototypeIcon.CUSTOM;
end 
end 

function name = getIconName( this, value )


idx = double( value ) + 1;
name = this.IconNames{ idx };
end 

function val = getConnectorStyleValue( this, name )
idx = strcmpi( name, this.LineStyleNames );
val = this.LineStyleValues( idx );
if isempty( val )
val = systemcomposer.internal.profile.ConnectorStyle.GENERIC;
end 
end 

function name = getConnectorStyleName( this, value )
idx = double( value ) + 1;
name = this.LineStyleNames{ idx };
end 

function cleanupObj = disableDefaultStereotypeAPIDeprecationWarning( ~ )
s = warning( 'off', 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' );
cleanupObj = onCleanup( @(  )warning( s ) );
end 

function setDefaultFunctionStereotype( this, funcSt )

if any( strcmpi( this.AppliesTo, 'component' ) )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.removeFunctionDefault;

if ~isempty( funcSt )
this.getImpl.defaultStereotypeMap.setFunctionDefault( funcSt.getImpl );
end 

txn.commit;
else 
error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
end 
end 

function defaultSt = getDefaultFunctionStereotype( this )


defaultSt = systemcomposer.profile.Stereotype.empty;
sImpl = this.getImpl.defaultStereotypeMap.getFunctionDefault;
if ~isempty( sImpl )
defaultSt = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 
end 
end 



methods ( Hidden )
function setDefaultComponentStereotype( this, compSt )


warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

if isempty( compSt )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.removeArchitectureDefault;
txn.commit;
return ;
end 

compSt = this.resolveStereotype( compSt );

if isempty( compSt )
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 


if compSt.Profile ~= this.Profile
error( message( 'SystemArchitecture:Profile:NoCrossProfileDefaults' ) );
end 

if any( strcmpi( this.AppliesTo, 'component' ) )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.setArchitectureDefault( compSt.getImpl );
txn.commit;
else 
error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
end 
end 

function setDefaultPortStereotype( this, portSt )


warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

if isempty( portSt )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.removePortDefault;
txn.commit;
return ;
end 

portSt = this.resolveStereotype( portSt );

if isempty( portSt )
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 


if portSt.Profile ~= this.Profile
error( message( 'SystemArchitecture:Profile:NoCrossProfileDefaults' ) );
end 

if any( strcmpi( this.AppliesTo, 'component' ) )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.setPortDefault( portSt.getImpl );
txn.commit;
else 
error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
end 
end 

function setDefaultConnectorStereotype( this, connSt )


warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

if isempty( connSt )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.removeConnectorDefault;
txn.commit;
return ;
end 

connSt = this.resolveStereotype( connSt );

if isempty( connSt )
error( message( 'SystemArchitecture:Profile:InputArgStereotypeNameOrObj' ) );
end 


if connSt.Profile ~= this.Profile
error( message( 'SystemArchitecture:Profile:NoCrossProfileDefaults' ) );
end 

if any( strcmpi( this.AppliesTo, 'component' ) )
txn = this.Model.beginTransaction;
this.getImpl.defaultStereotypeMap.setConnectorDefault( connSt.getImpl );
txn.commit;
else 
error( message( 'SystemArchitecture:Profile:CannotSetDefaultStereotype',  ...
this.FullyQualifiedName ) );
end 
end 

function defaultSt = getDefaultComponentStereotype( this )



warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

defaultSt = systemcomposer.profile.Stereotype.empty;
sImpl = this.getImpl.defaultStereotypeMap.getArchitectureDefault;
if ~isempty( sImpl )
defaultSt = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 
end 

function defaultSt = getDefaultPortStereotype( this )



warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

defaultSt = systemcomposer.profile.Stereotype.empty;
sImpl = this.getImpl.defaultStereotypeMap.getPortDefault;
if ~isempty( sImpl )
defaultSt = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 
end 

function defaultSt = getDefaultConnectorStereotype( this )



warning( message( 'SystemArchitecture:Profile:DefaultStereotypeAPIDeprecated' ) );

defaultSt = systemcomposer.profile.Stereotype.empty;
sImpl = this.getImpl.defaultStereotypeMap.getConnectorDefault;
if ~isempty( sImpl )
defaultSt = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 
end 

end 
end 

function mustBeMetaclassString( value )






validValues = { 'Component', 'Port', 'Connector', 'Interface', 'Function',  ...
'Requirement', 'Link', '' };

value = char( value );
valid = any( strcmp( value, validValues ) );
if ~valid
validStr = [ '''', char( join( string( validValues ), ''', ''' ) ), '''' ];
error( message( 'SystemArchitecture:Profile:InvalidAppliesToValue', validStr ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpA8XCFz.p.
% Please follow local copyright laws when handling this file.

