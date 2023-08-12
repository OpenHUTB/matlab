classdef VariablesManager < handle

properties 
Variables( :, 1 )cad.Variable
end 

methods 


function addVariable( self, Name, Value )







self.verifyName( Name );

if isnumeric( Value ) || isstring( Value ) || ischar( Value )

varObj = cad.Variable( Name, Value );


addVariableToStack( self, varObj );
elseif isa( Value, 'function_handle' )

expressionString = getExpressionWithoutInputs( self, Value );








[ funcHandle, depVars ] = parseExpression( self, expressionString );




varObj = cad.Variable( Name, funcHandle );


addVariableToStack( self, varObj );


for i = 1:numel( depVars )
depVars( i ).addVariableMap( varObj, 'Value' );
end 

end 
end 


function expn = getExpressionWithoutInputs( self, functionHandle )

expressionstring = func2str( functionHandle );


indx = self.strfindfirst( expressionstring, ')' );
expn = expressionstring( indx + 1:end  );
end 

function addVariableToStack( self, varObj )




idx = self.Variables == varObj;


if any( idx )
return ;
end 


self.Variables = [ self.Variables;varObj ];
end 

function removeVariablesFromStack( self, varObj )




idx = self.Variables == varObj;


if any( idx )
self.Variables = self.Variables( ~idx );
end 

end 

function verifyName( self, name )
R36
self
name{ mustBeValidVariableName }
end 

varnames = self.getVarNames(  );


idx = strcmp( name, varnames );
if any( idx )
error( message( "antenna:pcbantennadesigner:VariableExists" ) );
end 
end 

function varnames = getVarNames( self )

if isempty( self.Variables )
varnames = {  };
else 
varnames = { self.Variables.Name };
end 
end 

function changeVariableName( self, prevname, presentname )
varnames = getVarNames( self );
indx = strcmpi( varnames, prevname );
self.Variables( indx ).Name = presentname;
varObj = self.Variables( indx );
for i = 1:numel( varObj.VariableMap )
varObj.VariableMap( i ).variableNameUpdated( prevname, presentname );
end 
end 

function removeVariable( self, name )




if isempty( self.Variables )

return ;
end 

varnames = getVarNames( self );


idx = strcmpi( varnames, name );

if any( idx )


varObj = self.Variables( idx );


removeVariablesFromStack( self, varObj );

varObj.delete;
end 

end 

function set( self, name, value )


varnames = getVarNames( self );


idx = strcmpi( varnames, name );

if ~isempty( idx ) && any( idx )
varObj = self.Variables( idx );



if isa( value, 'function_handle' )

exprsn_string = getExpressionWithoutInputs( self, value );

[ fcnhandle, depvars, outputvalue ] = parseExpression( self, exprsn_string );



for i = 1:numel( varObj.VariableMap )
varObj.VariableMap( i ).verifyValidation( outputvalue );
end 


varObj.deleteDependentVariableMaps(  );

varObj.Value = fcnhandle;


for i = 1:numel( depvars )
verifyParentVariableNotEqual( self, depvars( i ), varObj );
end 

for i = 1:numel( depvars )
vmap = cad.VariableMap(  );
vmap.Variable = depvars( i );
vmap.PropertyName = 'Value';
vmap.DependentObject = varObj;
depvars( i ).addMapObjectToStack( vmap );
varObj.addDependentMapToStack( vmap );
end 

varObj.assignValueToProperty( 'Value', fcnhandle, [  ] );
else 


for i = 1:numel( varObj.VariableMap )
varObj.VariableMap( i ).verifyValidation( value );
end 


varObj.deleteDependentVariableMaps(  );


varObj.Value = value;
varObj.updateValue( value );
end 
end 

end 



function value = get( self, name )


varnames = getVarNames( self );


idx = strcmpi( varnames, name );

if ~isempty( idx ) && any( idx )
varObj = self.Variables( idx );


value = varObj.getValue(  );
else 
error( message( "antenna:pcbantennadesigner:VariableDoesnotExist", name ) );
end 

end 

function mapVariable( self, varname, object, property )



varnames = getVarNames( self );


idx = strcmpi( varnames, varname );

if ~isempty( idx ) && any( idx )
varObj = self.Variables( idx );
varObj.addVariableMap( object, property );
end 

end 

function removeDependentVariableMaps( self, object, property )



R36
self( 1, 1 )cad.VariablesManager
object( 1, 1 )cad.DependentObject
property( 1, : )char
end 

dependentMaps = object.DependentMap;
for i = 1:numel( dependentMaps )

if strcmpi( dependentMaps( i ).PropertyName, property )
dependentMaps.delete;
end 
end 
end 

function [ Functionhandle, dependentVariables, outputVal ] = parseExpression( self, ExpressionString, varargin )



outputVal = verifyExpressionString( self, ExpressionString, varargin{ : } );

dependentVariables = [  ];


usedVars = {  };
for i = 1:numel( self.Variables )


matches = regexp( ExpressionString, [ '\w*', self.Variables( i ).Name, '\w*' ], 'match' );
if ~isempty( matches ) && any( strcmpi( matches, self.Variables( i ).Name ) )


usedVars = [ usedVars, { self.Variables( i ).Name } ];
if isempty( dependentVariables )
dependentVariables = self.Variables( i );
else 
dependentVariables = [ dependentVariables;self.Variables( i ) ];
end 
end 
end 


if ~isempty( ExpressionString )
Functionhandle = eval( [ '@(', strjoin( usedVars, ',' ), ')', ExpressionString ] );
else 
Functionhandle = [  ];
end 


end 

function verifyParentVariableNotEqual( self, depVar, var )
if var == depVar
error( message( "antenna:pcbantennadesigner:CannotSetVarNameToItself", var.Name ) );
end 
for i = 1:numel( depVar.DependentMap )
varobj = depVar.DependentMap( i ).Variable;
if varobj ~= var
try 
verifyParentVariableNotEqual( self, varobj, var );
catch 
error( message( "antenna:pcbantennadesigner:CannotSetVar", depVar.Name, var.Name ) );
end 
else 
error( message( "antenna:pcbantennadesigner:CannotSetVar", depVar.Name, var.Name ) );
end 
end 
end 

function val = verifyExpressionString( self, expnString, varargin )
if ~isempty( varargin )
acceptEmpty = varargin{ 1 };
else 
acceptEmpty = 0;
end 



for i = 1:numel( self.Variables )




eval( [ self.Variables( i ).Name, ' = ', mat2str( self.Variables( i ).getValue ), ';' ] );

end 



if acceptEmpty && isempty( expnString )
val = [  ];
else 
val = eval( expnString );

end 


if isempty( val ) && ~acceptEmpty
error( message( "antenna:pcbantennadesigner:OutputEmpty" ) );
elseif isa( val, 'function_handle' )
error( message( "antenna:pcbantennadesigner:OutputFunctionHandle" ) );
end 

cad.DependentObject.AdditionalValidation( val );

end 

function location = strfindfirst( self, lookin, lookfor )


location = strfind( lookin, lookfor );
if ~isempty( location )
location = location( 1 );
end 
end 

function varobj = getVarObj( self, name )
varnames = getVarNames( self );
indx = strcmpi( varnames, name );
varobj = self.Variables( indx );
end 

function setValueToObject( self, object, propertyname, value, varargin )
if isa( value, 'function_handle' )


[ funchandle, depvars, outputVal ] = parseExpression( self, getExpressionWithoutInputs( self, value ), varargin{ : } );
valhandle = object.getValidation( propertyname );
valhandle( outputVal );
else 
varnames = getVarNames( self );
if any( strcmpi( varnames, value ) )
valueisvarname = 1;
else 
valueisvarname = 0;
end 


valhandle = object.getValidation( propertyname );
if ~valueisvarname

valhandle( value );
else 


[ funchandle, depvars, outputVal ] = parseExpression( self, value, varargin{ : } );
valhandle( self.get( value ) );
end 
end 


mapstack = object.DependentMap;
for i = 1:numel( mapstack )
if strcmpi( mapstack( i ).PropertyName, propertyname )
mapstack( i ).delete;
end 
end 

if isa( value, 'function_handle' )
object.PropertyValueMap.( propertyname ) = funchandle;
for i = 1:numel( depvars )
finalmapobj = depvars( i ).addVariableMap( object, propertyname );
end 
finalmapobj.valueUpdated(  );
else 
object.PropertyValueMap.( propertyname ) = [  ];
if valueisvarname
object.PropertyValueMap.( propertyname ) = funchandle;
for i = 1:numel( depvars )
finalmapobj = depvars( i ).addVariableMap( object, propertyname );
end 
finalmapobj.valueUpdated(  );
else 
assignValueToProperty( object, propertyname, value, [  ] );
end 
end 
end 

function copyObj = copy( self )
copyObj = cad.VariablesManager;
for i = 1:numel( self.Variables )

varObj = self.Variables( i );
if isempty( varObj.DependentMap )
copyObj.addVariable( varObj.Name, varObj.Value );
end 
end 
for i = 1:numel( self.Variables )


varObj = self.Variables( i );
if ~isempty( varObj.DependentMap )
copyObj.addVariable( varObj.Name, varObj.Value );
end 
end 

varNames1 = self.getVarNames(  );
varnames2 = copyObj.getVarNames(  );

[ ~, idx1 ] = sort( varNames1 );
[ ~, idx2 ] = sort( varnames2 );

vars = copyObj.Variables;
vars = vars( idx2 );
[ ~, newidx ] = sort( idx1 );
vars = vars( newidx );
copyObj.Variables = vars;

end 

function rtn = getIndepVarNames( self )
indepVarObj = getIndepVarObj( self );
rtn = { indepVarObj.Name };
end 

function rtn = getIndepVarObj( self )
idx = [  ];
for i = 1:numel( self.Variables )


varObj = self.Variables( i );
if isempty( varObj.DependentMap ) && ~isempty( varObj.VariableMap )
idx = [ idx, i ];
end 
end 
rtn = self.Variables( idx );
end 

function delete( self )
end 


end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYHN8LJ.p.
% Please follow local copyright laws when handling this file.

