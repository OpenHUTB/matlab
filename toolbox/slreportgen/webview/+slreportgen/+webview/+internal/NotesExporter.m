classdef NotesExporter < slreportgen.webview.internal.ExporterInterface
























properties ( Constant, Access = private )
CacheFileName string = "notes.mat";
end 

properties ( Access = private )
Printer
RouteMap

ModelCache
NotesCache
TypesCache
HasCache logical = false;
IsCacheModified logical = false;
end 

properties ( Access = private, Constant )
INTERNAL_TYPE = 1;
EXTERNAL_TYPE = 2;
INHERIT_TYPE = 3;
NONE_TYPES = [ 4, 5,  - 1 ];
end 

methods 
function this = NotesExporter( director )
this = this@slreportgen.webview.internal.ExporterInterface( director );
this.Printer = simulink.notes.internal.NotesPrinter(  );
this.RouteMap = dictionary( string.empty(  ), slreportgen.webview.internal.Diagram.empty(  ) );
end 

function export( this )


project = this.project(  );
project.ExportData.HasNotes = any( strlength( [ project.Models.Notes ] ) > 0 );
nDiagrams = numel( project.Diagrams );
nProcessed = 0;
models = project.Models;
for i = 1:numel( models )
model = models( i );
this.openNotesCache( model );
if ~isempty( model.Notes )
diagrams = model.Diagrams;
for j = 1:numel( diagrams )
diagram = diagrams( j );
if this.ProgressMonitor.isCanceled(  )
return 
end 
if diagram.Selected
this.exportDiagramNotes( diagram, Force = false );
end 
nProcessed = nProcessed + 1;
this.ProgressMonitor.setValue( nProcessed / nDiagrams );
end 
end 
this.closeNotesCache( model );
end 
end 
end 

methods ( Access = private )
function exportDiagramNotes( this, diagram, options )
R36
this
diagram
options.Force logical = false;
end 

switch this.getNoteType( diagram )
case this.INTERNAL_TYPE
this.exportInternalNotes( diagram, options.Force );
case this.EXTERNAL_TYPE
this.exportExternalNotes( diagram, options.Force );
case this.INHERIT_TYPE
this.exportInheritedNotes( diagram );
otherwise 
this.exportNoNotes( diagram );
end 
end 

function exportInternalNotes( this, diagram, force )


this.RouteMap( diagram.FullName ) = diagram;

if ( diagram.Selected || force )
pm = this.ProgressMonitor;
pkgPath = this.packagePath( diagram );
if ~isempty( this.NotesCache ) && this.NotesCache.isKey( diagram.FullName )

pm.setMessage(  ...
sprintf( "Notes: Exporting ""%s"" from cache", diagram.FullName ),  ...
pm.LowLevelMessagePriority );
this.addFile( this.ModelCache.getFile( this.cachePath( diagram ) ), pkgPath );
diagram.ExportData.Notes = this.NotesCache( diagram.FullName );
else 

pm.setMessage(  ...
sprintf( "Notes: Exporting ""%s"" from Simulink", diagram.FullName ),  ...
pm.LowLevelMessagePriority );
notesPath = this.filePath( diagram );

fid = fopen( notesPath, "w", "n", "UTF-8" );
content = this.Printer.getNotesHTMLFromHID( diagram.hid( Validate = false ) );

content = strrep( content, '.rtcContent { padding: 30px; }', '.rtcContent { padding: 0px; }' );
fprintf( fid, "%s", content );
fclose( fid );

this.addFile( notesPath, pkgPath );
notes = struct(  ...
"type", "internal",  ...
"data", pkgPath );
diagram.ExportData.Notes = notes;



if this.HasCache
this.ModelCache.addFile( notesPath, this.cachePath( diagram ) );
this.NotesCache( diagram.FullName ) = notes;
this.IsCacheModified = true;
end 
end 
end 
end 

function exportExternalNotes( this, diagram, force )


this.RouteMap( diagram.FullName ) = diagram;

if ( diagram.Selected || force )
pm = this.ProgressMonitor;
if ~isempty( this.NotesCache ) && this.NotesCache.isKey( diagram.FullName )

pm.setMessage(  ...
sprintf( "Notes: Exporting ""%s"" from cache", diagram.FullName ),  ...
pm.LowLevelMessagePriority );
diagram.ExportData.Notes = this.NotesCache( diagram.FullName );
else 

pm.setMessage(  ...
sprintf( "Notes: Exporting ""%s"" from Simulink", diagram.FullName ),  ...
pm.LowLevelMessagePriority );
notes = struct(  ...
"type", "external",  ...
"data", string( this.Printer.getNotesHTMLFromHID( diagram.hid( Validate = false ) ) ) );
diagram.ExportData.Notes = notes;



if this.HasCache
this.NotesCache( diagram.FullName ) = notes;
this.IsCacheModified = true;
end 
end 
end 
end 

function exportInheritedNotes( this, diagram )
if diagram.Selected
parent = diagram.Parent;
srcDiagram = [  ];
while ~isempty( parent )
if isempty( parent )
break ;
end 
if this.RouteMap.isKey( parent.FullName )
srcDiagram = this.RouteMap( parent.FullName );
break ;
end 
parent = parent.Parent;
end 

if ~isempty( srcDiagram )
if srcDiagram.Selected
diagram.ExportData.Notes = struct(  ...
"type", "inherit",  ...
"data", srcDiagram.ExportData.ID );
else 

this.exportDiagramNotes( this, srcDiagram, Force = true )
diagram.ExportData.Notes = srcDiagram.ExportData.Notes;
srcDiagram.ExportData.Notes = [  ];
this.RouteMap( srcDiagram.FullName ) = diagram;
end 
end 
end 
end 

function exportNoNotes( ~, diagram )
diagram.ExportData.Notes = [  ];
end 

function openNotesCache( this, model )
this.ModelCache = this.cache( model.Name );
if isempty( this.ModelCache )
this.HasCache = false;
this.NotesCache = [  ];
this.TypesCache = [  ];
elseif this.ModelCache.hasFile( this.CacheFileName )
this.HasCache = true;
this.IsCacheModified = false;
tmp = load( this.ModelCache.getFile( this.CacheFileName ) );
this.NotesCache = tmp.notes;
this.TypesCache = tmp.types;
else 
this.HasCache = true;
this.IsCacheModified = false;
this.NotesCache = dictionary( string.empty(  ), struct.empty(  ) );
this.TypesCache = dictionary( string.empty(  ), double.empty(  ) );
end 
end 

function closeNotesCache( this, model )
if this.HasCache && this.IsCacheModified
modelCache = this.cache( model.Name );
cacheFilePath = modelCache.createFile( this.CacheFileName );
notes = this.NotesCache;
types = this.TypesCache;
save( cacheFilePath, "notes", "types" );
end 
end 

function type = getNoteType( this, diagram )
if ~isempty( this.TypesCache ) && this.TypesCache.isKey( diagram.FullName )
type = this.TypesCache( diagram.FullName );
else 
try 

hid = diagram.hid( Validate = false );
type = this.Printer.getNotesType( hid );
catch 
hid = diagram.hid(  );
type = this.Printer.getNotesType( hid );
end 

if this.HasCache
this.TypesCache( diagram.FullName ) = type;
this.IsCacheModified = true;
end 
end 
end 

function out = fileName( ~, diagram )


out = sprintf( "%s_notes.html", escapeSID( diagram.RSID ) );
end 

function out = cachePath( this, diagram )
fileName = this.fileName( diagram );
out = compose( "notes/%s", fileName );
end 

function out = filePath( this, diagram )
fileName = this.fileName( diagram );
out = fullfile( this.supportFolderPath(  ), fileName );
end 

function out = packagePath( this, diagram )
fileName = this.fileName( diagram );
out = strcat( this.supportPackagePath(  ), "/", fileName );
end 
end 
end 

function out = escapeSID( sid )
out = sid.replace( ":", "_" );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpp9V2px.p.
% Please follow local copyright laws when handling this file.

