classdef ( Sealed, Hidden )CompositeScriptHelper < handle




properties ( SetAccess = immutable )
OutputSymbol char
OutputProperty char
DefaultOutputVar char
end 

properties ( SetAccess = private )
ScriptBuilder = coderapp.internal.script.ScriptBuilder(  )
end 

properties ( SetAccess = private )
Instantiator char = '[]'
end 

properties ( Access = private )
InstantiatorArgs cell = {  }
InstantiatorArgStr char = ''
SubValues struct = struct( 'key', {  }, 'property', {  }, 'code', {  } )
end 

methods 
function this = CompositeScriptHelper( ownKey, ownProp, defaultOutputVar, propMappings )
R36
ownKey{ mustBeTextScalar( ownKey ) }
ownProp{ mustBeTextScalar( ownProp ) }
defaultOutputVar{ mustBeTextScalar( defaultOutputVar ) }
propMappings cell = {  }
end 

this.OutputSymbol = ownKey;
this.OutputProperty = ownProp;
this.DefaultOutputVar = defaultOutputVar;

if ~isempty( propMappings )
this.init( propMappings );
end 
end 

function init( this, propMappings )
R36
this( 1, 1 )
propMappings( :, 2 ){ mustBeText( propMappings ) }
end 

this.SubValues = cell2struct( [ cellstr( propMappings ), cell( size( propMappings, 1 ), 1 ) ],  ...
{ 'key', 'property', 'code' }, 2 );
end 

function setInstantiator( this, factory, factoryArgs )
R36
this( 1, 1 )
factory char
factoryArgs cell = {  }
end 

this.Instantiator = factory;
if ~isequal( this.InstantiatorArgs, factoryArgs )
this.InstantiatorArgs = factoryArgs;
for i = 1:numel( factoryArgs )
factoryArgs{ i } = coderapp.internal.value.valueToExpression( factoryArgs{ i } );
end 
argStr = strjoin( factoryArgs, ', ' );
this.InstantiatorArgStr = argStr;
else 
argStr = this.InstantiatorArgStr;
end 
if ~isempty( factory )
if nargin > 2
this.Instantiator = sprintf( '%s(%s)', factory, argStr );
else 
this.Instantiator = factory;
end 
else 
this.Instantiator = '';
end 
end 

function changed = updateValues( this, values, validate )
R36
this
values( 1, 1 )struct
validate( 1, 1 )logical = false
end 

fields = fieldnames( values );
for i = 1:numel( fields )
values.( fields{ i } ) = coderapp.internal.value.valueToExpression( values.( fields{ i } ) );
end 
changed = this.updateSnippets( values, validate );
end 

function changed = updateSnippets( this, snippets, validate )
R36
this
snippets( 1, 1 )struct
validate( 1, 1 )logical = false
end 

[ ~, svIdx ] = intersect( { this.SubValues.key }, fieldnames( snippets ), 'stable' );
changed = ~validate;

for i = reshape( svIdx, 1, [  ] )
key = this.SubValues( i ).key;
current = snippets.( key );
prev = this.SubValues( i ).code;
if isempty( current )
current = [  ];
end 
this.SubValues( i ).code = current;
changed = changed || ~isequal( current, prev );
end 
if validate && changed
this.revalidate(  );
end 
end 

function revalidate( this )





scriptBuilder = coderapp.internal.script.ScriptBuilder(  ) ...
.input( this.OutputSymbol, '' ) ...
.transformInput( this.OutputSymbol, @( symbols )this.appendToPath( symbols ) );
if ~isempty( this.Instantiator )
scriptBuilder = scriptBuilder.append( sprintf( '`%s` = %s;\n',  ...
this.OutputSymbol, this.Instantiator ) );
end 

actives = this.SubValues;
propagateOutputFun = @( symbols )this.propagateOwnOutput( symbols );

for active = reshape( actives, 1, [  ] )
if isempty( active.code )
continue 
end 
if ischar( active.code )
statement = coderapp.internal.script.ScriptBuilder(  ...
sprintf( '`%s`.%s = %s;\n', this.OutputSymbol, active.property, active.code ) ) ...
.annotate( 'param', active.key );
scriptBuilder = scriptBuilder.append( statement );
else 
scriptBuilder = scriptBuilder.transformInput( active.key, propagateOutputFun ).append( active.code );
end 
end 

this.ScriptBuilder = scriptBuilder;
end 
end 

methods ( Access = private )
function result = appendToPath( this, symbols )
injected = symbols.( this.OutputSymbol );
if isempty( injected ) || isempty( this.OutputProperty )
result = this.DefaultOutputVar;
if isempty( result )
result = this.OutputSymbol;
end 
else 
result = [ injected, '.', this.OutputProperty ];
end 
end 

function result = propagateOwnOutput( this, symbols )
result = symbols.( this.OutputSymbol );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpHAeNCV.p.
% Please follow local copyright laws when handling this file.

