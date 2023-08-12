classdef BaseComponent < systemcomposer.arch.Element & systemcomposer.base.BaseComponent




properties 
Name
end 

properties ( SetAccess = private, Abstract )
Architecture
end 

properties ( SetAccess = private )
Parent
Ports
OwnedPorts
OwnedArchitecture
Parameters
end 

properties ( Dependent = true )
Position
end 


methods ( Hidden )
function this = BaseComponent( archElemImpl )
this@systemcomposer.arch.Element( archElemImpl );
archElemImpl.cachedWrapper = this;
end 

function fullName = getQualifiedName( this )
fullName = this.ElementImpl.getQualifiedName(  );
end 

function ports = getActivePorts( this )

if isa( this.Parent.Parent, 'systemcomposer.arch.VariantComponent' )


variantComp = this.Parent.Parent;
parentPorts = variantComp.getActivePorts;
ports = systemcomposer.arch.ComponentPort.empty( numel( parentPorts ), 0 );
cnt = 1;
for i = 1:numel( parentPorts )
p = this.getPort( parentPorts( i ).Name );
if ~isempty( p )
ports( cnt ) = p;
cnt = cnt + 1;
end 
end 
else 
ports = this.Ports;
end 
end 
function tf = isPropertyValueDefault( this, qualifiedPropName )
tf = isPropertyValueDefault@systemcomposer.arch.Element( this.Architecture, qualifiedPropName );
end 

function exposeParameter( this, varargin )
if ~this.isReference
this.Architecture.exposeParameter( varargin{ : } );
else 
error( 'systemcomposer:Parameter:CannotExposeToReferenceComp',  ...
message( 'SystemArchitecture:Parameter:CannotExposeToReferenceComp',  ...
this.Name, this.Architecture.Name ).getString );
end 
end 

end 

methods ( Static )
function comp = current(  )
comp = systemcomposer.arch.Component.empty;
mdl = systemcomposer.arch.Model.current(  );
if ~isempty( mdl ) && ~isempty( gcb )
comp = mdl.lookup( 'Path', gcb );
end 
end 
end 

methods 
function name = get.Name( this )
name = this.ElementImpl.getName;
end 

function parent = get.Parent( this )
parent = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getParentArchitecture, 'systemcomposer.arch.Architecture' );
end 

function set.Name( this, newName )
set_param( this.getQualifiedName, 'Name', newName );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
end 

function set.Position( this, pos )
set( this.SimulinkHandle, 'Position', pos );
end 

function pos = get.Position( this )
pos = get( this.SimulinkHandle, 'Position' );
end 

function ownedArch = get.OwnedArchitecture( this )
ownedArch = systemcomposer.arch.Architecture.empty( 1, 0 );
if this.ElementImpl.hasOwnedArchitecture
ownedArch = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getOwnedArchitecture, 'systemcomposer.arch.Architecture' );
end 
end 

function ports = get.Ports( this )
ch = this.ElementImpl.getPorts;
ports = systemcomposer.arch.ComponentPort.empty( numel( ch ), 0 );
for i = 1:numel( ch )
ports( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ), 'systemcomposer.arch.ComponentPort' );
end 
end 

function ports = get.OwnedPorts( this )
if ~this.isReference
ch = this.ElementImpl.getPorts;
ports = systemcomposer.arch.ComponentPort.empty( numel( ch ), 0 );
for i = 1:numel( ch )
ports( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ), 'systemcomposer.arch.ComponentPort' );
end 
end 
end 

function names = getStereotypes( this )


names = getStereotypes@systemcomposer.arch.Element( this.Architecture );
end 

function props = getStereotypeProperties( this )



props = getStereotypeProperties@systemcomposer.arch.Element( this.Architecture );
end 

function [ propExpr, propUnits ] = getProperty( this, qualifiedPropName )







[ propExpr, propUnits ] = getProperty@systemcomposer.arch.Element( this.Architecture, qualifiedPropName );
end 

function tf = hasProperty( this, qualifiedPropName )
tf = false;
arch = this.Architecture;
if ~isempty( arch )
tf = hasProperty@systemcomposer.arch.Element( arch, qualifiedPropName );
end 
end 

function setProperty( this, qualifiedPropName, propExpr, propUnit )






if nargin < 4
propUnit = '';
end 
setProperty@systemcomposer.arch.Element( this.Architecture, qualifiedPropName, propExpr, propUnit );

end 

function val = getPropertyValue( this, qualifiedPropName )





val = getPropertyValue@systemcomposer.arch.Element( this.Architecture, qualifiedPropName );
end 

function val = getEvaluatedPropertyValue( this, qualifiedPropName )






val = getEvaluatedPropertyValue@systemcomposer.arch.Element( this.Architecture, qualifiedPropName );
end 


function destroy( this )
delete_block( this.getQualifiedName );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
end 

function isRef = isReference( this )

if ( this.SimulinkHandle > 0 )
bh = this.SimulinkHandle;
bt = get_param( bh, "BlockType" );
isRef = false;
if strcmp( bt, "ModelReference" )
isRef = true;
elseif strcmp( bt, "SubSystem" )
isRef = systemcomposer.internal.isSubsystemReferenceComponent( bh );
end 
else 
compImpl = this.getImpl;
isRef = compImpl.isReferenceComponent || compImpl.isImplComponent;
end 
end 

function isProt = isProtected( this )


isProt = false;
if ( ~this.isReference )
return ;
end 

if ( this.SimulinkHandle > 0 &&  ...
strcmpi( get_param( this.SimulinkHandle, "ProtectedModel" ), "on" ) )
isProt = true;
else 
try 
compImpl = this.getImpl;
zcModelImpl = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf.zero.getModel( compImpl.getArchitecture ) );
isProt = zcModelImpl.isProtectedModel;
catch 
end 
end 
end 

function port = getPort( this, name )
port = systemcomposer.arch.ComponentPort.empty;
portObj = this.ElementImpl.getPort( name );
if ( ~isempty( portObj ) )
port = systemcomposer.internal.getWrapperForImpl( portObj );
end 
end 

function removeStereotype( this, stereotypeName )
removeStereotype@systemcomposer.base.StereotypableElement( this.Architecture, stereotypeName );
end 

cList = connect( this, otherComp, varargin );
applyStereotype( this, stereotype );

function prmNames = getParameterNames( this )
prmNames = string( this.ElementImpl.getParameterNames );
end 

function [ value, unit, isDefault ] = getParameterValue( this, paramFQN )


valStruct = this.getImpl.getParamVal( paramFQN );
value = valStruct.expression;
unit = valStruct.units;
isDefault = this.getImpl.isParamValDefault( paramFQN );
if this.getImpl.hasReferencedArchitecture && this.getImpl.isImplComponent && isDefault && ~this.isProtected
refArch = this.getImpl.getArchitecture;
refZCModel = systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel( refArch.getName );
if ~isequal( refZCModel.getLoadStatus, systemcomposer.architecture.model.core.ModelLoadState.FULLY_LOADED )
value = '<default>';
end 
end 
end 

function [ val, unit ] = getEvaluatedParameterValue( this, paramFQN )

valStruct = this.ElementImpl.getParamVal( paramFQN );
val = [  ];
unit = valStruct.units;

if ~isempty( valStruct.expression )
def = this.Architecture.ElementImpl.getParameterDefinition( paramFQN );
if ~isempty( def )
val = this.castValueToCorrectDataType( def.type, valStruct.expression );
end 
end 
end 

function setParameterValue( this, paramFQN, value, unit )
R36
this{ mustBeA( this, 'systemcomposer.arch.BaseComponent' ) }
paramFQN{ mustBeTextScalar }
value{ mustBeTextScalar }
unit{ mustBeTextScalar } = ''
end 
paramName = paramFQN;
if this.isReference

this.getImpl.fullyLoadParameterDefinitons( paramFQN );
systemcomposer.internal.arch.internal.updateInstanceParamsInSL( this.getImpl, paramFQN, 'Value', value );
else 

blockH = this.SimulinkHandle;

if strlength( value ) == 0
value = '[]';
end 
mask = get_param( blockH, 'MaskObject' );
if isempty( mask ) || isempty( mask.getParameter( paramFQN ) )

archImpl = this.Architecture.getImpl;
compPromotedFrom = archImpl.getComponentPromotedFrom( paramFQN );
if ~isempty( compPromotedFrom )
compWrapper = systemcomposer.internal.getWrapperForImpl( compPromotedFrom );
paramName = archImpl.getRelativeParameterFQN( compPromotedFrom, paramFQN );
compWrapper.setParameterValue( paramName, value );
end 
else 
set_param( blockH, paramName, value );
end 
end 
end 

function resetParameterToDefault( this, paramFQN )
paramFQN = string( paramFQN );
if ( this.isReference )

systemcomposer.internal.arch.internal.updateInstanceParamsInSL( this.getImpl, paramFQN, 'Value', '' );
else 

blockH = this.SimulinkHandle;
mask = get_param( blockH, 'MaskObject' );
if isempty( mask ) || isempty( mask.getParameter( paramFQN ) )

archImpl = this.Architecture.getImpl;
compPromotedFrom = archImpl.getComponentPromotedFrom( paramFQN );
if ~isempty( compPromotedFrom )
compWrapper = systemcomposer.internal.getWrapperForImpl( compPromotedFrom );
pName = archImpl.getRelativeParameterFQN( compPromotedFrom, paramFQN );
compWrapper.resetParameterToDefault( pName );
end 
else 
mp = mask.getParameter( paramFQN );
set_param( blockH, paramFQN, mp.DefaultValue );
end 
end 
end 

function setUnit( this, paramFQN, unit )

this.ElementImpl.setParamUnit( paramFQN, unit );
end 

function params = get.Parameters( this )
paramNames = this.getParameterNames;
params = systemcomposer.arch.Parameter.empty( numel( paramNames ), 0 );
for i = 1:numel( paramNames )
params( i ) = systemcomposer.arch.Parameter.wrapper( this, paramNames( i ) );
end 
end 

function param = getParameter( this, name )
paramNames = this.getParameterNames;
if any( ismember( paramNames, string( name ) ) )
param = systemcomposer.arch.Parameter.wrapper( this, name );
end 
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_vQ4LD.p.
% Please follow local copyright laws when handling this file.

