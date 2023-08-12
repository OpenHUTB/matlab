function dlg = slOpenViewMarkDialog( option )



vm = DAStudio.ViewmarkManager;
v = DAStudio.Viewmarker.getInstance;

if nargin > 0 && ~isempty( option )
vm.option = option;
modelname = option.model;
else 
vm.option.model = bdroot;
vm.option.mode = 'open';

editor = DAStudio.Viewmarker.getEditor(  );
[ ~, ~, modelname ] = DAStudio.Viewmarker.getFullModelName( editor.getName );
end 

app = DAS.Studio.getAllStudiosSortedByMostRecentlyActive.App;
currentEditor = app.getActiveEditor;


pos = currentEditor.getCanvas.GlobalPosition;

if currentEditor == v.getCurrentEditorHandle(  )
currentTime = clock(  );

if strcmp( vm.option.mode, 'open' ) && ~isempty( v.getLastClosedTime(  ) )
if etime( currentTime, v.getLastClosedTime(  ) ) < 0.5
dlg = [  ];
return ;
end 
end 
end 

v.setLastClosedTime( clock(  ) );
v.setCurrentEditorHandle( currentEditor );


vm.pos = pos;
size = [ pos( 3 ), pos( 4 ) ];

if strcmp( vm.option.mode, 'open' )
v.background( size );
end 

vm.viewmarker = v;
vm.modelname = modelname;

try 
dlg = DAStudio.Dialog( vm );
catch 
slprivate( 'slsfviewmark', bdroot, 'updateSelfie' );
dlg = DAStudio.Dialog( vm );
end 
openedModel = get_param( bdroot, 'filename' );
[ dir, filename, ext ] = fileparts( openedModel );
if ( strcmp( vm.option.mode, 'open' ) )

loaded = "false";
ticStart = tic;
while ( loaded ~= "true" )
loaded = dlg.evalBrowserJS( 'viewmarker_manager', 'document.fullyLoaded' );


elapsedTime = toc( ticStart );
if ( elapsedTime > 5 )
loaded = "true";
end 
end 

if ( ext ~= ".slx" )
dlg.evalBrowserJS( 'viewmarker_manager', 'enableManageButton(false)' );
end 
openedModels = find_system( 'type', 'block_diagram' );
for x = 1:length( openedModels )
dlg.evalBrowserJS( 'viewmarker_manager', [ 'updateRefreshButton("', openedModels{ x }, '")' ] );
end 
end 

pageWidth = pos( 3 );
pageHeight = pos( 4 );
SVG_ASPECT_RATIO = 570 / 365;
VIEWMARK_FIRST_TOLOAD_INDEX = v.findIndexForModelGroup( modelname );

if pageWidth > 1800
numberPerRow = 6;
elseif pageWidth > 1500
numberPerRow = 5;
elseif pageWidth > 1200
numberPerRow = 4;
elseif pageWidth > 900
numberPerRow = 3;
elseif pageWidth > 500
numberPerRow = 2;
else 
numberPerRow = 2;
end 

rowPerViewPort = floor( pageHeight / ( ( pageWidth - 20 ) / numberPerRow / SVG_ASPECT_RATIO ) );

onloadSVGResizeBegin = max( VIEWMARK_FIRST_TOLOAD_INDEX - numberPerRow, 0 );
onloadSVGResizeEnd = min( VIEWMARK_FIRST_TOLOAD_INDEX + numberPerRow * ( rowPerViewPort + 1 ), v.getLength(  ) );

indexArray = onloadSVGResizeBegin:onloadSVGResizeEnd;
len = onloadSVGResizeEnd - onloadSVGResizeBegin;

if nargin == 0 || ~strcmp( option.mode, 'creation' )
for i = 1:len
v.initialLoadSingle( dlg, indexArray( i ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCNT8FY.p.
% Please follow local copyright laws when handling this file.

