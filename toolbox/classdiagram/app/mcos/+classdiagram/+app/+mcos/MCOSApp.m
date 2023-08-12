classdef MCOSApp < classdiagram.app.core.ClassDiagramApp


properties ( Access = private )
Factory classdiagram.app.mcos.MCOSClassDiagramFactory;
ClassBrowser classdiagram.app.mcos.ClassBrowser;
ContentProvider;
ContentDataModel mdom.DataModel;
end 

methods 
function obj = MCOSApp( varargin )
obj = obj@classdiagram.app.core.ClassDiagramApp( varargin{ : } );
packages = {  };
if ~isempty( varargin ) && ~isempty( varargin{ 1 } )
packages = varargin{ 1 }.Packages;
end 
factory = obj.getClassDiagramFactory(  );
obj.ClassBrowser = classdiagram.app.mcos.ClassBrowser( obj, factory, packages );
obj.cdWindow.url = [ obj.cdWindow.url, '&dataModelID=', obj.ClassBrowser.getDataModelID(  ) ];
rootItems = cellfun( @( r )r.getObjectID, obj.ClassBrowser.getRootNodes(  ) );
obj.ContentProvider = classdiagram.app.mcos.MCOSContentProvider( factory, rootItems );

function dm = initializeDataModel( provider, queryString )
dm = mdom.DataModel( provider );
obj.cdWindow.url = [ obj.cdWindow.url, [ '&', queryString, '=' ], dm.getID ];

dm.columnChanged( 1, {  } );
dm.rowChanged( '', provider.RootCount, {  } );
end 

obj.ContentDataModel = initializeDataModel( obj.ContentProvider, 'viewContentModelID' );
end 

function dp = getContentProvider( self )
dp = self.ContentProvider;
end 

function navigateToSource( self, classInfo )
emptyClasses = string.empty( 1, 0 );
errClasses = string.empty( 1, 0 );
msg = message.empty( 1, 0 );
for ii = 1:numel( classInfo )
navInfo = classInfo( ii );
idParts = string( navInfo.objectID ).split( "|" );
packageElementName = idParts( end  );

obj = self.Factory.getNonCachedPackageElement( packageElementName );
if isempty( obj )
emptyClasses( end  + 1 ) = packageElementName;%#ok<AGROW>                   
continue ;
end 
metadataMap = obj.getMetadata(  );
if metadataMap.isKey( 'nosource' )
errClasses( end  + 1 ) = packageElementName;%#ok<AGROW>
continue ;
end 
try 

s = settings;
origShowNewFilePrompt = s.matlab.confirmationdialogs.EditorShowNewFilePrompt.ActiveValue;
origNamedBufferOption = s.matlab.confirmationdialogs.EditorNamedBufferOption.ActiveValue;
restoreSettings = onCleanup( @(  )self.setPromptingOptions(  ...
createNamedBuffer = origNamedBufferOption, showNewFilePrompt = origShowNewFilePrompt ) );

self.setPromptingOptions( createNamedBuffer = false, showNewFilePrompt = false );
if isempty( navInfo.memberName )
fp = which( packageElementName );
obj = matlab.desktop.editor.findOpenDocument( fp );
open( packageElementName );
if ~isempty( obj )

obj.goToLine( 1 );
end 
else 
packageElementName = strcat( packageElementName, ".", navInfo.memberName );
edit( packageElementName );
end 
catch ex
if strcmp( ex.identifier, 'MATLAB:Editor:FileNotFound' )
msg( end  + 1 ) = message( 'classdiagram_editor:messages:ErrMNotFoundDoRefresh',  ...
packageElementName );%#ok<AGROW>
else 
msg( end  + 1 ) = ex.message;%#ok<AGROW>
end 
end 
end 
if ~isempty( emptyClasses )
msg( end  + 1 ) = message( 'classdiagram_editor:messages:ErrMNotFoundDoRefresh',  ...
emptyClasses.join( "," ) );
end 
if ~isempty( errClasses )
msg( end  + 1 ) = message( 'classdiagram_editor:messages:ErrMNavigateToCode',  ...
errClasses.join( "," ) );
end 
if ~isempty( msg )
if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
self.notifier.processNotification( msg );
else 
self.notifier.processNotification(  ...
classdiagram.app.core.notifications.notifications.WDFNotification(  ...
msg,  ...
Transient = false,  ...
Severity = classdiagram.app.core.notifications.Severity.Error ) );
end 
end 
end 

function updateObjectInContentView( self, object )
for class = object
if ~isempty( class )
self.ContentProvider.updateClass( class );
end 
end 
self.ContentProvider.refreshHierarchy;
end 


function updatePackageInContentView( self, classOrPackage )
if isa( classOrPackage, 'classdiagram.app.core.domain.PackageElement' )
owningPackages = arrayfun( @( c )c.getOwningPackage, classOrPackage, 'uni', 0 );
package = [ owningPackages{ : } ];
else 
package = classOrPackage;
end 
for pkg = unique( package )
if ~isempty( pkg )
self.ContentProvider.updatePackage( pkg );
end 
end 
self.ContentProvider.refreshHierarchy;
end 

function show( self, isDebug )
if ~exist( 'isDebug', 'var' )
isDebug = false;
end 
show@classdiagram.app.core.ClassDiagramApp( self, isDebug );
end 
end 

methods ( Access = protected )
function factory = virtualGetClassDiagramFactory( self )
if isempty( self.Factory )
self.Factory = classdiagram.app.mcos.MCOSClassDiagramFactory( self );
end 
factory = self.Factory;
end 

function cb = virtualGetClassBrowser( self )
cb = self.ClassBrowser;
end 
end 

methods ( Access = private )
function setPromptingOptions( ~, options )
R36
~;
options.createNamedBuffer logical = false;
options.showNewFilePrompt logical = false;

end 

if ~options.createNamedBuffer
createNamedBuffer = 2;
else 
createNamedBuffer = 1;
end 

s = settings;
s.matlab.confirmationdialogs.EditorNamedBufferOption.TemporaryValue = createNamedBuffer;
s.matlab.confirmationdialogs.EditorShowNewFilePrompt.TemporaryValue = options.showNewFilePrompt;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKtbQaz.p.
% Please follow local copyright laws when handling this file.

