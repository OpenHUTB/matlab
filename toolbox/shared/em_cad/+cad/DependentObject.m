classdef DependentObject < handle



properties 


DependentMap( :, 1 )

end 

properties ( Hidden = true )
PropertyValueMap = struct( 'Property', [  ] );
ObjectType = 'DependentObject';
end 

properties ( Constant )

NoValidationHandle = @( x )x;
AdditionalValidation = @( x )validateattributes( x, { 'double' }, { 'nonnan', 'finite', 'real' } );
end 

methods 

function updateVariableNameInHandle( self, property, prevname, presentname )
propfcnhandle = self.PropertyValueMap.( property );
newhandle = replaceVarInfcnHandle( self, propfcnhandle, prevname, presentname );
self.PropertyValueMap.( property ) = newhandle;
end 

function newfcn = replaceVarInfcnHandle( self, fcnhandle, prevname, presentname )
fcnstr = func2str( fcnhandle );
fcnstr = regexprep( fcnstr, [ '\<', prevname, '\>' ], presentname );
newfcn = str2func( fcnstr );
end 

function self = DependentObject(  )

end 

function additionalValidation( self, validationHandle, value )

if isnumeric( value )
self.AdditionalValidation( value );
end 
end 

















function addDependentMapToStack( self, varMapObj )



R36
self( 1, 1 )cad.DependentObject
varMapObj( 1, 1 )cad.VariableMap
end 

idx = self.DependentMap == varMapObj;
if any( idx )

return ;
end 


self.DependentMap = [ self.DependentMap;varMapObj ];
end 

function assignValueToProperty( self, PropertyName, Value, varname )





R36
self( 1, 1 )cad.DependentObject %#ok<INUSA> 
PropertyName( 1, : )char
Value
varname = [  ]
end 

PropertyName = Value;%#ok<NASGU> 

end 

function removeDependentMapFromStack( self, varMapObj )



R36
self( 1, 1 )cad.DependentObject
varMapObj( 1, 1 )cad.VariableMap
end 
if isempty( self.DependentMap )
return ;
end 

idx = self.DependentMap == varMapObj;

if any( idx )

self.DependentMap( idx ) = [  ];
end 
end 

function delete( self )





deleteDependentVariableMaps( self );
end 

function deleteDependentVariableMaps( self )








mapStack = self.DependentMap;
for i = 1:numel( mapStack )


if ~isvalid( mapStack( i ) )
continue ;
end 
mapStack( i ).delete;
end 
end 

function expn = getExpressionWithoutInputs( self, functionHandle )

expressionstring = func2str( functionHandle );


indx = self.strfindfirst( expressionstring, ')' );
expn = expressionstring( indx + 1:end  );
end 

function location = strfindfirst( self, lookin, lookfor )


location = strfind( lookin, lookfor );
if ~isempty( location )
location = location( 1 );
end 
end 

function validationHandleOut = getDefaultValidation( self, propName )
validationHandleOut = self.NoValidationHandle;
end 

function validationHandleOut = getValidation( self, propName, varname )



R36
self( 1, 1 )cad.DependentObject
propName( 1, : )char %#ok<INUSA> % property name must be a string
varname( 1, : )char = ''
end 






if ~any( strcmpi( propName, fields( self.PropertyValueMap ) ) )
error( message( 'MATLAB:noSuchMethodOrField', propName, self.ObjectType ) );
return ;
end 










if isempty( varname ) || isempty( self.PropertyValueMap.( propName ) )
validationHandleOut = self.getDefaultValidation( propName );
else 
varnames = regexp( getExpressionWithoutInputs( self, self.PropertyValueMap.( propName ) ), [ '\w*', varname, '\w*' ], 'match' );

propNames = arrayfun( @( x )x.PropertyName,  ...
self.DependentMap, 'UniformOutput', false );
idx = strcmpi( propNames, propName );
propMaps = self.DependentMap( idx );
argsArray = generateArgsArray( self, propMaps );

mapVarnames = arrayfun( @( x )x.getVarName(  ),  ...
propMaps, 'UniformOutput', false );

idx = strcmpi( mapVarnames, varname );

if any( idx )




indexnum = find( idx );
nummaps = numel( self.DependentMap );
propFuncHandle = self.PropertyValueMap.( propName );
if indexnum == 1
validationHandle = @( x )propFuncHandle( x, argsArray{ ~idx } );
elseif indexnum == nummaps
validationHandle = @( x )propFuncHandle( argsArray{ ~idx }, x );
else 
validationHandle = @( x )propFuncHandle( argsArray{ 1:indexnum - 1 }, x, argsArray{ indexnum + 1:end  } );
end 


defaultValidation = getDefaultValidation( self, propName );


validationHandleOut = @( x )defaultValidation( validationHandle( x ) );
else 
validationHandleOut = self.NoValidationHandle;

end 
end 
end 

function argsArray = generateArgsArray( self, maps )

argsArray = cell( numel( maps ), 1 );
for i = 1:numel( maps )


argsArray{ i } = maps( i ).getValue(  );
end 
end 

function Opvalue = getValueOfProperty( self, propname, value, varname )
if ~strcmpi( propname, fields( self.PropertyValueMap ) )
error( message( 'MATLAB:noSuchMethodOrField', propname, self.ObjectType ) );
end 
if isempty( varname ) || isempty( self.PropertyValueMap.( propname ) )
Opvalue = value;
else 
try 
propNames = arrayfun( @( x )x.PropertyName,  ...
self.DependentMap, 'UniformOutput', false );
idx = strcmpi( propNames, propname );
propMaps = self.DependentMap( idx );


argsArray = generateArgsArray( self, propMaps );
Opvalue = self.PropertyValueMap.( propname )( argsArray{ : } );
catch me
Opvalue = me;
end 
end 
end 

function copyPropertyValueMap( self, targetObj, vm )
props = fields( self.PropertyValueMap );
for i = 1:numel( props )
if ~isempty( self.PropertyValueMap.( props{ i } ) )
vm.setValueToObject( targetObj, props{ i }, self.PropertyValueMap.( props{ i } ) );
end 
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4fIdT6.p.
% Please follow local copyright laws when handling this file.

