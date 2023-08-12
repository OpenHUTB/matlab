classdef Cache < handle



































properties ( SetAccess = private )


ModelName string


Libraries
end 

properties ( Access = private )


PropertyMap



FileMap


Checksums
end 

properties ( Transient, Access = private )


IsOpen logical = false;




BaseFolder


IsModified logical


ResolvedDependencies


ModelExists logical


PreCloseCallbacks
end 

properties ( Constant, Access = private )

MementoFileName string = "memento.mat";
end 

methods 
function open( this )





if ~this.IsOpen
mlreportgen.utils.internal.logmsg( compose( "Unpacking: %s", this.ModelName ) );
this.IsModified = false;
this.IsOpen = true;
builtin( '_unpackSLCacheSLWebView', char( this.ModelName ) );
mementoFile = this.mementoFilePath(  );
if isfile( mementoFile )

tmp = load( mementoFile );
memento = tmp.memento;
this.Libraries = memento.Libraries;
this.PropertyMap = memento.PropertyMap;
this.FileMap = memento.FileMap;
this.Checksums = memento.Checksums;
else 
this.clear(  );
end 
end 
end 

function close( this, options )



R36
this
options.Save logical = logical.empty(  );
end 

if this.IsOpen
if this.isModelOpenAndDirty(  )
mlreportgen.utils.internal.logmsg( compose( "Not Repacking." ) );
builtin( '_packSLCacheSLWebView', char( this.ModelName ), false );
else 

for i = 1:numel( this.PreCloseCallbacks )
try 
feval( this.PreCloseCallbacks{ i }, this );
catch ME
warning( ME.message );
end 
end 

if isempty( options.Save )
options.Save = this.IsModified;
end 

if options.Save

this.updateChecksum(  );

memento = this;
save( this.mementoFilePath(  ), "memento" );
end 
mlreportgen.utils.internal.logmsg( compose( "Repacking: %d", options.Save ) );
builtin( '_packSLCacheSLWebView', char( this.ModelName ), options.Save );
end 
this.IsModified = false;
this.IsOpen = false;
end 
end 

function tf = isOpen( this )



tf = this.IsOpen;
end 

function tf = isModified( this )



tf = this.IsModified;
end 

function clear( this )




this.open(  );
folder = this.BaseFolder;
if isfolder( folder )
rmdir( folder, "s" );
mkdir( folder );
end 

this.FileMap = containers.Map( 'KeyType', 'char', 'ValueType', 'logical' );
this.PropertyMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
this.Libraries = {  };
this.IsModified = true;
end 

function out = createFile( this, cachePath )





R36
this
cachePath string
end 
assert( this.IsOpen );
cachePath = normalizeCachePath( cachePath );
out = this.BaseFolder + filesep(  ) + strrep( cachePath, "/", filesep(  ) );
folder = fileparts( out );
if ~isfolder( folder )
mkdir( folder );
end 
this.FileMap( cachePath ) = true;
this.IsModified = true;
end 

function addFile( this, file, cachePath )



R36
this
file string
cachePath string
end 
assert( this.IsOpen );
cachePath = normalizeCachePath( cachePath );
cacheFilePath = this.BaseFolder + filesep(  ) + strrep( cachePath, "/", filesep(  ) );
cacheFolder = fileparts( cacheFilePath );
if ~isfolder( cacheFolder )
mkdir( cacheFolder )
end 
copyfile( file, cacheFilePath, "f" );
this.FileMap( cachePath ) = true;
this.IsModified = true;
end 

function tf = hasFile( this, cachePath )




R36
this
cachePath string
end 
assert( this.IsOpen );
cachePath = normalizeCachePath( cachePath );
tf = ~isempty( cachePath ) && this.FileMap.isKey( cachePath );
end 

function file = getFile( this, cachePath )



R36
this
cachePath string
end 
assert( this.IsOpen );
cachePath = normalizeCachePath( cachePath );
if this.hasFile( cachePath )
file = this.BaseFolder + filesep(  ) + strrep( cachePath, "/", filesep(  ) );
assert( isfile( file ) );
else 
file = string.empty(  );
end 
end 

function addProperty( this, name, value )





R36
this
name string
value
end 
assert( this.IsOpen );
this.PropertyMap( name ) = value;
this.IsModified = true;
end 

function tf = hasProperty( this, name )



R36
this
name string
end 
assert( this.IsOpen );
tf = this.PropertyMap.isKey( name );
end 

function value = getProperty( this, name )



R36
this
name string
end 
assert( this.IsOpen );
value = this.PropertyMap( name );
end 

function tf = isModelOpenAndDirty( this )




tf = inmem( '-isloaded', this.ModelName ) ...
 && strcmp( get_param( this.ModelName, "Dirty" ), "on" );

if ~tf

n = numel( this.Libraries );
i = 0;
while ( ~tf && ( n > i ) )
i = i + 1;
library = this.Libraries{ i };
tf = inmem( '-isloaded', library ) ...
 && strcmp( get_param( library, "Dirty" ), "on" );
end 
end 
end 

function addPreCloseCallback( this, fcn )
if isempty( this.PreCloseCallbacks )
this.PreCloseCallbacks = {  };
end 
this.PreCloseCallbacks{ end  + 1 } = fcn;
end 
end 

methods ( Access = ?slreportgen.webview.internal.ModelBuilder )
function addLibraryDependency( this, library )
this.Libraries{ end  + 1 } = library;
this.ResolvedDependencies = [  ];
end 
end 

methods ( Access = ?slreportgen.webview.internal.CacheManager )
function this = Cache( modelName, baseFolder )
this.ModelExists = ( exist( modelName, "file" ) == 4 );
assert( this.ModelExists || exist( modelName + ".slxc", "file" ) )
this.IsOpen = false;
this.IsModified = false;
this.ModelName = modelName;
this.BaseFolder = baseFolder;
end 

function tf = isValid( this )
assert( this.IsOpen );
tf = false;
if isempty( this.Checksums )
tf = true;
elseif ~this.ModelExists
tf = true;
else 
actualChecksums = this.calculateChecksum(  );
if isequaln( this.Checksums, actualChecksums )
names = fieldnames( this.Checksums );
for i = 1:numel( names )
name = names{ i };
if ( isempty( this.Checksums.( name ) ) || isempty( actualChecksums.( name ) ) )
return ;
end 
end 
tf = true;
end 
end 
end 
end 

methods ( Access = private )
function updateChecksum( this )
modelFile = this.modelChecksumFilePath(  );
modelFolder = fileparts( modelFile );
if ~isfolder( modelFolder )
mkdir( modelFolder );
end 
this.Checksums = this.calculateChecksum(  );


fid = fopen( modelFile, "w", "n", "UTF-8" );
fprintf( fid, "%s", this.Checksums.( this.ModelName ) );
fclose( fid );
end 

function out = calculateChecksum( this )
out = struct(  );
[ names, files ] = this.dependencies(  );
for i = 1:numel( names )
name = names( i );
try 
if ~( inmem( "-isloaded", name ) && strcmp( get_param( name, "Dirty" ), "on" ) )
out.( name ) = mlreportgen.utils.internal.md5sum( files( i ) );
else 
out.( name ) = [  ];
end 
catch 
out.( name ) = [  ];
end 
end 
end 

function [ names, files ] = dependencies( this )
if isempty( this.ResolvedDependencies )
names = string( [ this.ModelName, this.Libraries ] );
n = numel( names );
files = string.empty( 0, n );
for i = 1:n
name = names( i );
if inmem( '-isloaded', name )
files( i ) = get_param( name, 'FileName' );
else 
files( i ) = which( name );
end 
end 
this.ResolvedDependencies = struct(  ...
'Names', names,  ...
'Files', files );
end 

names = this.ResolvedDependencies.Names;
files = this.ResolvedDependencies.Files;
end 

function file = modelChecksumFilePath( this )
file = this.BaseFolder + filesep(  ) + this.ModelName + ".md5";
end 

function file = mementoFilePath( this )
file = this.BaseFolder + filesep(  ) + this.MementoFileName;
end 
end 
end 

function cachePath = normalizeCachePath( cachePath )
cachePath = replace( cachePath, "\", "/" );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ3LhwD.p.
% Please follow local copyright laws when handling this file.

