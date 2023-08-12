classdef ( Sealed )ParamTypeManager < handle


properties ( SetAccess = immutable )
UserVisibleStrategy coderapp.internal.config.UserVisibleDataObjectStrategy
BaseStrategy coderapp.internal.config.DataObjectStrategy
end 

properties ( GetAccess = private, SetAccess = immutable )
ParamTypes
end 

properties ( Dependent, GetAccess = private, SetAccess = immutable )
AllTypes
end 

methods 
function this = ParamTypeManager( paramTypes )
R36
paramTypes = [  ]
end 

this.ParamTypes = containers.Map(  );
[ this.UserVisibleStrategy, this.BaseStrategy ] = this.registerCoreTypes(  );

if ~isempty( paramTypes )
this.registerTypes( paramTypes );
end 
end 

function yes = isType( this, name )
yes = this.ParamTypes.isKey( name );
end 

function type = getType( this, name )
if ischar( name )
type = this.ParamTypes( name );
else 
type = this.ParamTypes.values( name );
type = [ type{ : } ];
end 
end 

function allTypes = get.AllTypes( this )
if ~isempty( this.ParamTypes )
allTypes = this.ParamTypes.values(  );
allTypes = [ allTypes{ : } ];
else 
allTypes = [  ];
end 
end 
end 

methods ( Access = { ?coderapp.internal.config.ParamTypeManager, ?coderapp.internal.config.SchemaValidator,  ...
?coderapp.internal.config.Schema } )
function registerTypes( this, paramTypes )
if ischar( paramTypes ) || isstring( paramTypes )
paramTypes = cellfun( @( t )coderapp.internal.util.instantiateByName( t,  ...
'coderapp.internal.config.AbstractParamType' ), cellstr( paramTypes ) );
elseif isobject( paramTypes )
assert( isa( paramTypes, 'coderapp.internal.config.AbstractParamType' ),  ...
'Param types must inherit from AbstractParamType' );
end 
for type = reshape( paramTypes, 1, [  ] )
if this.isType( type.Name )
error( 'Type with name "%s" is already registered', type.Name );
end 
this.ParamTypes( type.Name ) = type;
end 
end 
end 

methods ( Access = private )
function [ uvs, bs ] = registerCoreTypes( this )
persistent coreTypes sharedUvs sharedBs;
if isempty( coreTypes )
coreTypes = [ 
coderapp.internal.config.type.StringParamType(  )
coderapp.internal.config.type.IntegerParamType(  )
coderapp.internal.config.type.DoubleParamType(  )
coderapp.internal.config.type.BooleanParamType(  )
coderapp.internal.config.type.FileParamType(  )
coderapp.internal.config.type.EnumParamType(  )
coderapp.internal.config.type.IntegerArrayParamType(  )
coderapp.internal.config.type.DoubleArrayParamType(  )
coderapp.internal.config.type.FileArrayParamType(  )
coderapp.internal.config.type.StringArrayParamType(  )
coderapp.internal.config.type.EnumArrayParamType(  )
coderapp.internal.config.type.CompositeParamType(  )
 ];
sharedUvs = coderapp.internal.config.UserVisibleDataObjectStrategy(  ...
'coderapp.internal.config.data.UserVisibleData' );
sharedBs = coderapp.internal.config.DataObjectStrategy(  ...
'coderapp.internal.config.data.DataObject' );
end 
uvs = sharedUvs;
bs = sharedBs;
this.registerTypes( coreTypes );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3AJsuQ.p.
% Please follow local copyright laws when handling this file.

