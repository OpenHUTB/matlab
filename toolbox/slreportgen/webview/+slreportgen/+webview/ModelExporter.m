classdef ( Hidden )ModelExporter < handle




















properties 
SystemView;
OptionalViews;
IncludeNotes( 1, 1 )logical
end 

properties ( SetAccess = private )
Model;
ModelHierarchy;
HomeSystem;
HomeItem;
ProgressMonitor;
end 

properties ( Access = 'private' )
m_engine;

Document
Target
SupportPath
SupportFolder
end 

methods 
function h = ModelExporter( modelElement )
h.m_engine = slreportgen.webview.ExportEngine( h, modelElement );


h.Document = modelElement.Document;
h.Target = modelElement.SourceUrl;

[ trgPath, trgName ] = fileparts( h.Target );
h.SupportPath = sprintf( "%s/%s_files", trgPath, trgName );
h.SupportFolder = fullfile( h.Document.WorkingDir, h.SupportPath );

h.ProgressMonitor = slreportgen.webview.ProgressMonitor(  );

h.SystemView = slreportgen.webview.ViewExporter(  );
systemView = h.SystemView;
systemView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
systemView.InformerDataExporter = [  ];
systemView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );
systemView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
systemView.FinderDataExporter = slreportgen.webview.FinderDataExporter(  );
end 

function addFile( h, file, varargin )
addFile( h.m_engine, file, varargin{ : } );
end 

function export( h, systems, homeSystem, initialElement )
R36
h
systems
homeSystem = [  ]
initialElement = [  ]
end 


if isa( systems, 'slreportgen.webview.ModelHierarchy' )
modelHierarchy = systems;
else 
modelHierarchy = slreportgen.webview.ModelHierarchy( systems );
end 


if isa( homeSystem, 'slreportgen.webview.ModelHierarchyItem' )
assert( homeSystem.ModelHierarchy == modelHierarchy );
homeItem = homeSystem;
elseif ~isempty( homeSystem )
homeItem = getItem( modelHierarchy, homeSystem );
else 
homeItem = [  ];
end 
if isempty( homeItem )
rootItems = getRootItems( modelHierarchy );
homeItem = rootItems( 1 );
end 

h.Model = getDiagramBackingHandle( getRoot( homeItem ) );
h.ModelHierarchy = modelHierarchy;
h.HomeSystem = getDiagramBackingHandle( homeItem );
h.HomeItem = homeItem;


preExport( h );


export( h.m_engine, modelHierarchy, homeItem, initialElement );


postExport( h );
end 
end 

methods ( Access = private )
function preExport( h )

addChild( h.ProgressMonitor, h.m_engine.ProgressMonitor );


setModel( h.SystemView, h.Model );
setHomeSystem( h.SystemView, h.HomeSystem );
setSupportPath( h.SystemView, h.SupportPath );
setSupportFolder( h.SystemView, h.SupportFolder );
setIsSystemView( h.SystemView, true );

resetSupportFiles( h.SystemView );
preExport( h.SystemView, h );
preExportDataExporters( h.SystemView );


optionalViews = getEnabledOptionalViews( h.m_engine );
nOptionalViews = length( optionalViews );
for i = 1:nOptionalViews
optionalView = optionalViews{ i };

setModel( optionalView, h.Model );
setHomeSystem( optionalView, h.HomeSystem );

setSupportPath( optionalView, h.SupportPath );
setSupportFolder( optionalView, h.SupportFolder );

setIsSystemView( h.SystemView, false );

resetSupportFiles( optionalView );
preExport( optionalView, h );
preExportDataExporters( optionalView );
end 
end 

function postExport( h )

postExportDataExporters( h.SystemView );
postExport( h.SystemView );

[ files, paths ] = supportFiles( h.SystemView );
n = numel( files );
for i = 1:n
addFile( h.Document, files( i ), paths( i ) );
end 
resetSupportFiles( h.SystemView );

setModel( h.SystemView, [  ] );
setHomeSystem( h.SystemView, [  ] );

setSupportPath( h.SystemView, string.empty(  ) );
setSupportFolder( h.SystemView, string.empty(  ) );

setIsSystemView( h.SystemView, false );


optionalViews = getEnabledOptionalViews( h.m_engine );
nOptionalViews = length( optionalViews );
for i = 1:nOptionalViews
optionalView = optionalViews{ i };

postExportDataExporters( optionalView );
postExport( optionalView );

[ files, paths ] = supportFiles( optionalView );
n = numel( files );
for j = 1:n
addFile( h.Document, files( j ), paths( j ) );
end 
resetSupportFiles( optionalView );

setModel( optionalView, [  ] );
setHomeSystem( optionalView, [  ] );

setSupportPath( optionalView, string.empty(  ) );
setSupportFolder( optionalView, string.empty(  ) );

setIsSystemView( optionalView, false );
end 

h.HomeSystem = [  ];
h.Model = [  ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqWurqr.p.
% Please follow local copyright laws when handling this file.

