classdef Printer < handle



properties 
FilePath;
Extension;
DiagramToPrint;
CEFWindow;
end 

methods ( Static )
function takeScreenshotForView( view, filePath, options )








R36
view( 1, 1 )systemcomposer.view.View;
filePath{ mustBeText };
options.DiagramType{ mustBeMember( options.DiagramType, { 'ComponentDiagram', 'ComponentHierarchy', 'ClassDiagram' } ) } = 'ComponentDiagram';
end 

zcModel = view.Model;
app = systemcomposer.internal.arch.load( zcModel.Name );
appMgr = app.getArchViewsAppMgr;
if options.DiagramType ~= "ComponentDiagram"
if ( options.DiagramType == "ComponentHierarchy" )
diagram = appMgr.getClassDiagram( view.getImpl );
diagTypeEnum = systemcomposer.architecture.model.views.DiagramType.HIERARCHY;
else 
diagram = appMgr.getSWClassDiagram( view.getImpl );
diagTypeEnum = systemcomposer.architecture.model.views.DiagramType.CLASS;
end 
else 
diagram = appMgr.getSyntaxSystem( view.getImpl );
diagTypeEnum = systemcomposer.architecture.model.views.DiagramType.COMPONENT;
end 
url = appMgr.buildURLForScreenshot( view.getImpl, diagTypeEnum );
printer = systemcomposer.internal.editor.Printer( filePath, diagram, url );
printer.printToFile(  );
end 

function takeScreenshotForDiagramUUID( modelName, diagramUUID, filePath )





R36
modelName{ mustBeText };
diagramUUID{ mustBeText };
filePath{ mustBeText };
end 

app = systemcomposer.internal.arch.load( modelName );
appMgr = app.getArchViewsAppMgr;
syntax = appMgr.getSyntax;
diagram = syntax.getModel.findElement( diagramUUID );
if ~isa( diagram, 'sysarch.syntax.architecture.System' )
diagram = syntax.findElement( diagramUUID );
end 
url = appMgr.buildURLForScreenshot( diagramUUID );

printer = systemcomposer.internal.editor.Printer( filePath, diagram, url );
printer.printToFile(  );
end 
end 

methods 
function obj = Printer( filePath, diagram, url )
obj.FilePath = obj.validateFilePath( filePath );
obj.DiagramToPrint = diagram;
[ ~, ~, obj.Extension ] = fileparts( filePath );
url = connector.getUrl( url );
geometry = obj.getGeometryForCEFWindow(  );
opts = { 'Position';geometry };
obj.CEFWindow = matlab.internal.webwindow( url, opts{ : } );
obj.CEFWindow.hide(  );
drawnow;


obj.waitingOnServerResponse( obj.CEFWindow );
end 

function printToFile( obj )

if ( strcmpi( obj.Extension, '.pdf' ) )
obj.CEFWindow.printToPDF( obj.FilePath );
drawnow;
else 
img = obj.CEFWindow.getScreenshot(  );
imwrite( img, obj.FilePath );
drawnow;
end 
delete( obj.CEFWindow );
end 
end 

methods ( Access = private )
function filePath = validateFilePath( ~, filePath )
if isempty( filePath )
error( 'A valid file path must be provided' );
end 
[ path, fileName, ext ] = fileparts( filePath );
if isempty( path )
path = pwd;
end 
if isempty( ext )
error( 'Extension must be provided' );
end 
filePath = fullfile( path, [ fileName, ext ] );
end 

function status = waitingOnServerResponse( obj, window )
import matlab.unittest.constraints.Eventually;
import matlab.unittest.constraints.IsFalse;

pollingConstraint = Eventually( IsFalse );
status = pollingConstraint.satisfiedBy( @(  )obj.isCommandCenterWaitingOnServerResponse( window ) );
pause( 1 );
end 

function result = isCommandCenterWaitingOnServerResponse( ~, wt )
result = strcmpi( wt.executeJS( 'window.editor !== undefined && window.editor.isScreenshotReady === true' ), 'false' );
end 

function boundingSize = getBoundingBoxSizeForClassDiagramEnities( ~, entities )

maxRight = 0;
maxBottom = 0;

for i = 1:numel( entities )
size = entities( i ).getSize;
position = entities( i ).getPosition;
right = position.x + size.width;
bottom = position.y + size.height;
maxRight = max( maxRight, right );
maxBottom = max( maxBottom, bottom );
end 

boundingSize = [ 0, 0, maxRight, maxBottom ];

end 

function geometry = getGeometryForCEFWindow( obj )
geometry = systemcomposer.internal.editor.ZCViewsWindow.WindowSize;
if ( strcmpi( obj.Extension, '.pdf' ) )

if isa( obj.DiagramToPrint, 'sysarch.syntax.architecture.System' )
geometry( 3 ) = obj.DiagramToPrint.systemBox.size.width;
geometry( 4 ) = obj.DiagramToPrint.systemBox.size.height;
else 
boundingSize = obj.getBoundingBoxSizeForClassDiagramEnities( obj.DiagramToPrint.entities );
geometry( 3 ) = boundingSize( 3 );
geometry( 4 ) = boundingSize( 4 );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOxX8c8.p.
% Please follow local copyright laws when handling this file.

