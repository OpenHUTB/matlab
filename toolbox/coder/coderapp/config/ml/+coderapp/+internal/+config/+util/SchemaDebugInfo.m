classdef ( Sealed )SchemaDebugInfo < handle





properties ( Constant, Access = private )
IS_DEVELOPMENT = ~isempty( which( 'coderapp.dev.config.locateDefinitions' ) )
end 

properties ( SetAccess = ?coderapp.internal.config.SchemaValidator )
RootFile{ mustBeTextScalar( RootFile ) } = ''
MixinRootFiles{ mustBeText( MixinRootFiles ) } = {  }
FragmentFiles{ mustBeText( FragmentFiles ) } = {  }
end 

properties ( SetAccess = private )
Info table = table( {  }, {  }, {  }, {  }, [  ], [  ], 'VariableNames', { 
'Key'
'Type'
'Root'
'Fragment'
'TextStart'
'TextEnd'
 } )
end 

methods ( Access = ?coderapp.internal.config.SchemaValidator )
function appendDefinition( this, type, key, rootFile, fragmentFile )
R36
this( 1, 1 )
type
key
rootFile = ''
fragmentFile = ''
end 

this.Info( end  + 1, : ) = { key, type, rootFile, fragmentFile, 0, 0 };
end 
end 

methods 
function relativizeFromMatlabRoot( this )
this.RootFile = doRelativize( this.RootFile );
this.MixinRootFiles = doRelativize( this.MixinRootFiles );
this.FragmentFiles = doRelativize( this.FragmentFiles );
this.Info.Root = doRelativize( this.Info.Root );
this.Info.Fragment = doRelativize( this.Info.Fragment );
end 
end 

methods 
function ownership = getInfo( this, key, align )
R36
this( 1, 1 )
key{ mustBeTextScalar( key ) }
align = false
end 

select = ismember( this.Info.Key, key );
if align
row = this.doAlign( Select = select, Silent = false );
else 
row = this.Info( select, : );
end 
ownership = table2struct( row );
end 

function goTo( this, key, opts )
R36
this( 1, 1 )
key{ mustBeTextScalar( key ) }
opts.UseVsCode
opts.ReuseVsCodeWindow
end 

assert( this.IS_DEVELOPMENT, 'goTo is only supported in a development environment' );
info = this.getInfo( key, true );
file = info.Fragment;
if isempty( file )
file = info.Root;
end 
args = namedargs2cell( opts );
coderapp.dev.openTextEditor( 'File', file, 'Position', info.TextStart, args{ : } );
end 

function align( this, keys )
R36
this( 1, 1 )
keys{ mustBeText( keys ) } = {  }
end 

if ~isempty( keys )
select = ismember( this.Info.Key, keys );
else 
select = true( size( this.Info, 1 ), 1 );
end 
this.doAlign( Select = select, Force = true, Silent = false );
end 
end 

methods ( Access = private )
function rows = doAlign( this, opts )
R36
this
opts.Select = true( size( this.Info, 1 ), 1 )
opts.Silent = true
opts.Force = false
end 

rows = this.Info( opts.Select, : );
if ~this.IS_DEVELOPMENT
if opts.Silent
return 
else 
error( 'align is only supported in a development environment' );
end 
end 

locsByFile = containers.Map(  );
changed = false;

for i = 1:size( rows, 1 )
if ~opts.Force && rows.TextStart( i ) == 0 && rows.TextEnd( i ) == 0
continue 
end 
file = rows.Fragment{ i };
if isempty( file )
file = rows.Root{ i };
end 
if isempty( file ) || ~isfile( file )
continue 
end 
if locsByFile.isKey( file )
locMappings = locsByFile( file );
else 
locMappings = coderapp.dev.config.locateDefinitions( file );
locsByFile( file ) = locMappings;
end 
key = rows.Key{ i };
if isfield( locMappings, key )
interval = locMappings.( key );
rows.TextStart( i ) = interval( 1 );
rows.TextEnd( i ) = interval( 2 );
changed = true;
end 
end 

if changed
this.Info( opts.Select, : ) = rows;
end 
end 
end 
end 


function files = doRelativize( files )
multi = iscell( files );
files = cellstr( files );
isMatlabRoot = startsWith( files, matlabroot );
files( isMatlabRoot ) = extractAfter( files( isMatlabRoot ), numel( matlabroot ) + 1 );
if ~multi
files = files{ 1 };
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpgnTsDg.p.
% Please follow local copyright laws when handling this file.

