classdef ( Abstract, Hidden )AbstractEnumParamType < coderapp.internal.config.AbstractParamType



methods 
function this = AbstractEnumParamType( name, doClass, varargin )
this@coderapp.internal.config.AbstractParamType( name, doClass,  ...
{ 'AllowedValues',  ...
'ToCanonical', 'optionToValue',  ...
'FromCanonical', 'valueToOption',  ...
'FromSchema', 'schemaValueToOption' },  ...
varargin{ : } );
end 
end 

methods 
function resolveMessages( this, dataObj, unresolvedMsgs )
resolved = false( size( unresolvedMsgs ) );
for i = 1:numel( unresolvedMsgs )
unresolved = unresolvedMsgs( i );
if iscell( unresolved.Path ) && strcmp( unresolved.Path{ 1 }, 'AllowedValues' )
idx = unresolved.Path{ 2 };
if idx <= numel( dataObj.AllowedValues ) && isempty( dataObj.AllowedValues( idx ).DisplayValue )
dataObj.AllowedValues( idx ).DisplayValue = message( unresolved.MessageKey ).getString(  );
resolved( i ) = true;
end 
end 
end 
resolveMessages@coderapp.internal.config.AbstractParamType( this, dataObj, unresolvedMsgs( ~resolved ) );
end 

function choices = getTabCompletions( ~, input, dataObj )
options = dataObj.AllowedValues;
choices = { options( [ options.Enabled ] ).Value };
choices( ~startsWith( lower( choices ), lower( input ) ) ) = [  ];
end 
end 

methods ( Access = protected )
function attrs = doGetMessageKeyAttributes( this )
attrs = [ doGetMessageKeyAttributes@coderapp.internal.config.AbstractParamType( this ), { 'AllowedValues' } ];
end 
end 

methods ( Static, Access = protected )
function checkEnumValue( testValue, dataObj )
R36
testValue{ mustBeText( testValue ) }
dataObj = [  ];
end 
if ~isempty( dataObj )
valid = ismember( testValue, { dataObj.AllowedValues.Value } );
if ~all( valid )
error( '%s is not a valid enum value in %s',  ...
strjoin( strcat( '"', string( testValue ), '"' ), ', ' ),  ...
strjoin( strcat( '"', { dataObj.AllowedValues.Value }, '"' ), ', ' ) );
end 
end 
end 
end 

methods ( Static, Sealed )
function code = toCode( value )
code = coderapp.internal.config.type.AbstractStringParamType.toCode( value );
end 

function str = toString( values )
str = coderapp.internal.config.type.AbstractStringParamType.toString( values );
end 

function val = optionToValue( opt )
val = opt.Value;
end 

function [ opts, unresolvedMsgs ] = schemaValueToOption( val, mfzModel, escapeMode )
opts = coderapp.internal.config.type.AbstractEnumParamType.valueToOption( val );
unresolvedMsgs = coderapp.internal.config.schema.UnresolvedMessage.empty(  );
for i = 1:numel( opts )
if isempty( opts( i ).DisplayValue )
continue 
end 
[ str, isMsg ] = coderapp.internal.config.type.AbstractEnumParamType.unescapeString( opts( i ).DisplayValue, escapeMode );
if isMsg
idx = numel( unresolvedMsgs ) + 1;
unresolvedMsgs( idx ) = coderapp.internal.config.schema.UnresolvedMessage( mfzModel );
unresolvedMsgs( idx ).MessageKey = str;
unresolvedMsgs( idx ).Path = { 'AllowedValues', i };
str = '';
end 
opts( i ).DisplayValue = str;
end 
end 

function opt = valueToOption( val )
if isa( val, 'coderapp.internal.config.data.EnumOption' )
opt = val;
elseif iscell( val )
opt = repmat( coderapp.internal.config.data.EnumOption(  ), 1, numel( val ) );
for i = 1:numel( opt )
opt( i ) = coderapp.internal.config.type.AbstractEnumParamType.valueToOption( val{ i } );
end 
elseif isstring( val )
opt = coderapp.internal.config.type.AbstractEnumParamType.valueToOption( cellstr( val ) );
elseif ischar( val )
opt = coderapp.internal.config.data.EnumOption(  );
opt.Value = val;
elseif isstruct( val )
opt = repmat( coderapp.internal.config.data.EnumOption(  ), 1, numel( val ) );
val = coderapp.internal.config.type.AbstractEnumParamType.toPascalCaseStruct( val );
vals = { val.Value };
[ opt.Value ] = vals{ : };
if isfield( val, 'DisplayValue' )
vals = { val.DisplayValue };
[ opt.DisplayValue ] = vals{ : };
end 
if isfield( val, 'Enabled' )
vals = { val.Enabled };
[ opt.Enabled ] = vals{ : };
end 
else 
error( 'Unsupported enum option format' );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp5l5QsY.p.
% Please follow local copyright laws when handling this file.

