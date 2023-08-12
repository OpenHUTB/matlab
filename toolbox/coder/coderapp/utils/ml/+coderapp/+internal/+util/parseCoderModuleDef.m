


function def = parseCoderModuleDef( defFile )
R36
defFile char{ mustBeTextScalar( defFile ), mustBeNonzeroLengthText( defFile ) }
end 

resolvedFile = resolveFile( defFile );
if isempty( resolvedFile )
error( 'Could not locate file: %s', defFile );
end 
def = readAndValidate( resolvedFile );
end 


function def = readAndValidate( defFile )
def = jsondecode( fileread( defFile ) );
defRoot = fileparts( defFile );

def = validateField( def, 'provides', Validator = @mustBeText, Transformer = @cellstr, Default = {  } );
def = validateField( def, 'entryPointModule', Required = true, Validator = @mustBeAmdModuleId );

def = validateField( def, 'production', Required = true, Validator = @mustBeScalarStruct );
def.production = validateField( def.production, 'bundlePath', Required = true, Validator = @( v )mustHaveExtension( v, 'js' ) );
def.production = validateField( def.production, 'cssPath', Validator = @mustBeCssFile, Default = '' );

[ ~, bundlePath ] = resolveFile( def.production.bundlePath, defRoot );
if isempty( bundlePath )
error( 'Could not find bundle: %s', bundlePath );
else 
def.production.bundlePath = bundlePath;
end 

if ~isempty( def.production.cssPath )
[ ~, cssFile ] = resolveFile( def.production.cssPath, defRoot );
if isempty( cssFile )
error( 'Could not find CSS file at: %s', def.production.cssPath );
else 
def.production.cssPath = cssFile;
end 
end 

def = validateField( def, 'debug', Required = true, Validator = @mustBeScalarStruct );
def.debug = validateField( def.debug, 'cssPath', Required = ~isempty( def.production.cssPath ),  ...
Validator = @mustBeCssFile, Default = '' );
def.debug = validateField( def.debug, 'dependenciesFile', Validator = @( v )mustHaveExtension( v, 'json' ),  ...
Default = fullfile( defRoot, 'js_dependencies.json' ) );

if ~isempty( def.debug.cssPath )
[ ~, cssFile ] = resolveFile( def.debug.cssPath, defRoot );
if isempty( cssFile )
error( 'Could not find debug CSS file at: %s', def.debug.cssPath );
else 
def.debug.cssPath = cssFile;
end 
end 


[ depFile, def.debug.dependenciesFile ] = resolveFile( def.debug.dependenciesFile, defRoot );


if ~isempty( depFile )
def.debug.dependenciesJson = fileread( depFile );
else 
def.debug.dependenciesJson = '';
end 
end 


function [ resolved, normPath ] = resolveFile( file, relativeRoot )
R36
file char{ mustBeTextScalar( file ) }
relativeRoot char{ mustBeTextScalar( relativeRoot ) } = matlabroot(  )
end 

resolved = '';
normPath = '';
possibles = fullfile( unique( { '', relativeRoot, matlabroot(  ) }, 'stable' ), file );

for i = 1:numel( possibles )
if isfile( possibles{ i } )
resolved = codergui.internal.util.getCanonicalPath( possibles{ i } );
normPath = strrep( extractAfter( resolved, matlabroot(  ) ), '\', '/' );
break 
end 
end 
end 


function structVal = validateField( structVal, fld, opts )
R36
structVal( 1, 1 )struct
fld( 1, 1 )string
opts.Validator function_handle
opts.Transformer function_handle
opts.Default
opts.Required( 1, 1 )logical = false
end 

hasField = isfield( structVal, fld );
assert( ~opts.Required || hasField, 'Required field "%s" is missing' );

if ~hasField
if isfield( opts, 'Default' )
structVal.( fld ) = opts.Default;
end 
return 
end 

if isfield( opts, 'Validator' )
try 
opts.Validator( structVal.( fld ) );
catch me
error( 'Value for field "%s" is invalid: %s', fld, me.message );
end 
end 
if isfield( opts, 'Transformer' )
structVal.( fld ) = opts.Transformer( struct.( fld ) );
end 
end 


function mustBeScalarStruct( value )
validateattributes( value, { 'struct' }, { 'scalar' } );
end 


function mustBeAmdModuleId( value )
mustBeTextScalar( value );
assert( ~isempty( regexp( value, '^\w+\/(\w+\/)*\w+(?!\.js)$', 'once' ) ),  ...
'Must be a valid, absolute AMD module ID (e.g. mypackage/mymodule' );
end 


function mustBeCssFile( value )
mustHaveExtension( value, 'css' );
end 


function mustHaveExtension( value, extList )
R36
value( 1, 1 )string{ mustBeTextScalar( value ) }
end 
R36( Repeating )
extList char{ mustBeTextScalar( extList ) }
end 

[ ~, ~, ext ] = fileparts( value );
assert( ismember( ext, "." + string( extList ) ), 'Extension %s is not one of allowed: %s', ext, strjoin( extList, ', ' ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpexuwkA.p.
% Please follow local copyright laws when handling this file.

