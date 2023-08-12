classdef DataObjectStrategy < handle



properties ( SetAccess = immutable )
DataObjectClass char
end 

properties ( Transient, SetAccess = private )
MfzMetaClass mf.zero.meta.Class
end 

properties ( Dependent, SetAccess = immutable )
Attributes cell
MessageAttributes cell
end 

properties ( GetAccess = private, SetAccess = immutable )
DataObjectConstructor function_handle
end 

properties ( Access = private )
CachedAttributes
CachedMessageAttributes
end 

methods 
function this = DataObjectStrategy( dataObjectClass )
R36
dataObjectClass char{ mustBeValidDataObjectClass( dataObjectClass ) }
end 
this.DataObjectClass = dataObjectClass;
this.DataObjectConstructor = str2func( dataObjectClass );
end 
end 

methods 
function value = import( ~, attr, value )%#ok<*INUSL>
end 

function value = export( ~, attr, value )
end 

function [ value, unresolvedMsgs ] = fromSchema( ~, attr, value, varargin )%#ok<*INUSD>
unresolvedMsgs = [  ];
end 

function attrs = get.Attributes( this )
if ~iscell( this.CachedAttributes )
this.CachedAttributes = this.doGetAttributes(  );
end 
attrs = this.CachedAttributes;
end 

function attrs = get.MessageAttributes( this )
if ~iscell( this.CachedMessageAttributes )
this.CachedMessageAttributes = this.doGetMessageKeyAttributes(  );
end 
attrs = this.CachedMessageAttributes;
end 

function mc = get.MfzMetaClass( this )
mc = this.MfzMetaClass;
if isempty( mc )
mc = feval( [ this.DataObjectClass, '.StaticMetaClass' ] );
this.MfzMetaClass = mc;
end 
end 
end 

methods ( Sealed )
function dataObj = newDataObject( this, mfzModel, arg )
if nargin < 3
dataObj = this.DataObjectConstructor( mfzModel );
else 
dataObj = this.DataObjectConstructor( mfzModel, arg );
end 
end 
end 

methods ( Access = protected )
function attrs = doGetAttributes( this )
attrs = properties( this.DataObjectClass );
end 

function attrs = doGetMessageKeyAttributes( ~ )
attrs = {  };
end 
end 

methods ( Static, Hidden )
function result = toPascalCaseStruct( structArg )
fields = fieldnames( structArg );
removes = false( size( fields ) );
result = structArg;
for i = 1:numel( fields )
field = fields{ i };
if upper( field( 1 ) ) ~= field( 1 )
[ result.( [ upper( field( 1 ) ), field( 2:end  ) ] ) ] = result.( field );
removes( i ) = true;
end 
end 
result = rmfield( result, fields( removes ) );
end 

function result = toPascalCase( strs )
if iscell( strs )
result = strs;
for i = 1:numel( strs )
if isempty( strs{ i } )
continue 
end 
result{ i } = [ upper( strs{ i }( 1 ) ), strs{ i }( 2:end  ) ];
end 
elseif ~isempty( strs )
result = [ upper( strs( 1 ) ), strs( 2:end  ) ];
else 
result = strs;
end 
end 

function docRef = toDocRef( raw )
if isa( raw, 'coderapp.internal.util.DocRef' )
docRef = raw;
elseif coder.internal.isScalarText( raw )
docRef.TopicId = raw;
elseif isstruct( raw )
raw = coderapp.internal.config.DataObjectStrategy.toPascalCaseStruct( raw );
docRef = coderapp.internal.util.DocRef(  );
docRef.TopicId = raw.TopicId;
if isfield( raw, 'MapFile' )
if ~endsWith( raw.MapFile, '.map' )
error( 'Map files should have a .map extension: %s', file );
end 
docRef.MapFile = raw.MapFile;
end 
else 
error( 'Unexpected doc ref class "%s"', class( raw ) );
end 
end 
end 

methods ( Static )
function [ result, isMsg ] = unescapeString( str, escapeMode )
R36
str{ mustBeTextScalar( str ) }
escapeMode = coderapp.internal.config.schema.UserFacingStringEscape.ESCAPE_NONE
end 
str = char( str );
switch escapeMode
case coderapp.internal.config.schema.UserFacingStringEscape.ESCAPE_LITERALS
positive = false;
case coderapp.internal.config.schema.UserFacingStringEscape.ESCAPE_MESSAGES
positive = true;
otherwise 
result = str;
isMsg = false;
return 
end 
if startsWith( str, '{{' ) && endsWith( str, '}}' )
result = str( 3:end  - 2 );
isMsg = positive;
else 
result = str;
isMsg = ~positive;
end 
end 
end 
end 


function mustBeValidDataObjectClass( className )
if isempty( className )
return 
end 
if isempty( meta.class.fromName( className ) )
error( 'Could not load class "%s"', className );
end 
if ~ismember( 'coderapp.internal.config.data.DataObject', [ className;superclasses( className ) ] )
error( 'Class "%s" does not extend DataObject', className );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVOg8G7.p.
% Please follow local copyright laws when handling this file.

