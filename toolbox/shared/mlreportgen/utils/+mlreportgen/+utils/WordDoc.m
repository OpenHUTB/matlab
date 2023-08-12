classdef WordDoc < mlreportgen.utils.internal.OfficeDoc




































properties ( Hidden, Constant )
FileExtensions = [ ".docx", ".doc", ".rtf", ".txt", ".dotx" ];
end 

properties ( Access = private )
Updated = false;
end 

methods 
function this = WordDoc( fileName )





this = this@mlreportgen.utils.internal.OfficeDoc( fileName );
end 

function show( this )





hNETObj = netobj( this );
mlreportgen.utils.internal.executeRPC( @(  )showNETObj( hNETObj ) );
flush( this, 0 );
end 

function hide( this )



hNETObj = netobj( this );
if isVisible( this )
executeWithRetries( this, @(  )hideNETObj( hNETObj ) );
flush( this, 0 );
end 
end 

function tf = close( this, varargin )













import mlreportgen.utils.internal.waitFor
import mlreportgen.utils.internal.executeRPC

if isOpen( this )
closeFlag = isempty( varargin ) || logical( varargin{ 1 } );
hNETObj = netobj( this );


hApp = executeWithRetries( this, @(  )hNETObj.Application );
hDocs = executeWithRetries( this, @(  )hApp.Documents );
nDocs = executeWithRetries( this, @(  )hDocs.Count );


closeTF = executeWithRetries( this, @(  )closeNETObj( hNETObj, closeFlag ) );


countTF = waitFor( @(  )( executeRPC( @(  )hDocs.Count ) < nDocs ) );
tf = ( closeTF && countTF );

if tf

nFinalDocs = executeRPC( @(  )hDocs.Count );
if ( nFinalDocs == 0 )
executeRPC( @(  )hideAppNETObj( hApp ) );
end 


clearNETObj( this );
else 
flush( this );
end 
end 
end 

function update( this, ForceUpdate )



R36
this
ForceUpdate logical = false;
end 

if isReadOnly( this )
error( message( "mlreportgen:utils:error:cannotUpdateReadonlyDocument", this.FileName ) );
end 

if ( ~ForceUpdate && this.Updated && isSaved( this ) )
return 
end 



scopeHide = showWithCleanup( this );



scopeShowWhiteSpaceBetweenPage = showWhiteSpaceBetweenPage( this );


expandSubdocuments( this, "Show", false );


updateOLEObjects( this );


updateFields( this );


updateHeadersAndFooters( this );


updateTableOfContents( this );


updateTableOfFigures( this );


repaginate( this );


updateFields( this );


makeDirty( this );

this.Updated = true;
delete( scopeHide );
delete( scopeShowWhiteSpaceBetweenPage );
end 

function docFullPath = saveAsDoc( this, varargin )








docFullPath = saveAs( this,  ...
Microsoft.Office.Interop.Word.WdSaveFormat.wdFormatDocument,  ...
".doc",  ...
varargin{ : } );
end 

function textFullPath = saveAsText( this, varargin )









textFullPath = saveAs( this,  ...
Microsoft.Office.Interop.Word.WdSaveFormat.wdFormatText,  ...
".txt",  ...
varargin{ : } );
end 

function pdfFullPath = exportToPDF( this, varargin )









if isempty( varargin )
[ fPath, fName ] = fileparts( this.FileName );
pdfFile = fullfile( fPath, fName + ".pdf" );
else 
pdfFile = varargin{ 1 };
end 

pdfFullPath = string( mlreportgen.utils.internal.canonicalPath( pdfFile ) );
if isfile( pdfFullPath )
delete( pdfFullPath );
end 

hNETObj = netobj( this );
unset = System.Reflection.Missing.Value;
executeWithRetries( this, @(  )hNETObj.ExportAsFixedFormat(  ...
pdfFullPath,  ...
Microsoft.Office.Interop.Word.WdExportFormat.wdExportFormatPDF,  ...
false,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
true,  ...
unset,  ...
Microsoft.Office.Interop.Word.WdExportCreateBookmarks.wdExportCreateHeadingBookmarks,  ...
unset,  ...
unset,  ...
unset,  ...
unset ) );
mlreportgen.utils.internal.waitFor( @(  )isfile( pdfFullPath ) );
flush( this );
end 

function print( this, opts )













R36
this
opts.ScaleToFitPaper logical = false
end 

hNETObj = netobj( this );

origValue = executeWithRetries( this, @(  )hNETObj.Application.Options.MapPaperSize );
if ( opts.ScaleToFitPaper ~= origValue )


executeWithRetries( this, @(  )setMapPaperSize( hNETObj, opts.ScaleToFitPaper ) );

scopedRestoreMapPaperSize = onCleanup(  ...
@(  )executeWithRetries( this, @(  )setMapPaperSize( hNETObj, origValue ) ) );
end 

print@mlreportgen.utils.internal.OfficeDoc( this );
end 

function unlinkFields( this, varargin )













if this.isReadOnly(  )
error( message( "mlreportgen:utils:error:cannotUnlinkFieldsReadonlyDocument", this.FileName ) );
end 

hNETObj = netobj( this );
hFields = executeWithRetries( this, @(  )hNETObj.Fields );

if ~isempty( varargin )
unlinkTypes = string( varargin );
nUnlinkTypes = numel( unlinkTypes );

nFields = executeWithRetries( this, @(  )hFields.Count );
for i = nFields: - 1:1
hField = executeWithRetries( this, @(  )hFields.Item( i ) );
hFieldType = string( executeWithRetries( this, @(  )hField.Type ) );

for j = 1:nUnlinkTypes
unlinkType = unlinkTypes( j );
if strcmp( unlinkType, hFieldType )
executeWithRetries( this, @(  )hField.Unlink(  ) );
break ;
end 
end 
end 
else 
executeWithRetries( this, @(  )hFields.Unlink(  ) );
end 
flush( this );
end 

function unlinkSubdocuments( this )




if this.isReadOnly(  )
error( message( "mlreportgen:utils:error:cannotUnlinkReadonlyDocument", this.FileName ) );
end 

scopedHide = expandSubdocuments( this, "Show", true );

hNETObj = netobj( this );
executeWithRetries( this, @(  )unlinkSubdocNETObj( hNETObj ) );

flush( this );
delete( scopedHide );
end 

function tf = isReadOnly( this )




hNETObj = netobj( this );
tf = executeWithRetries( this, @(  )hNETObj.ReadOnly );
end 

function tf = isSaved( this )




hNETObj = netobj( this );
tf = executeWithRetries( this, @(  )hNETObj.Saved );
end 

function tf = isVisible( this )






hNETObj = netobj( this );
tf = mlreportgen.utils.internal.executeRPC( @(  )hNETObj.ActiveWindow.Visible );
end 
end 

methods ( Static, Access = protected )
function hNETObj = createNETObj( fullFilePath )
import mlreportgen.utils.internal.executeRPC


wc = mlreportgen.utils.WordDoc.controller(  );
start( wc );


wapp = app( wc );
hAppNETObj = netobj( wapp );
hDocs = executeRPC( @(  )hAppNETObj.Documents );


hNETObj = executeRPC( @(  )findDocNETObj( hDocs, fullFilePath ) );
if isempty( hNETObj )
hNETObj = executeRPC( @(  )openDocNETObj( hDocs, fullFilePath ) );
end 
end 

function flushNETObj( hNETObj )
hNETObj.Activate(  );
hNETObj.ActiveWindow.Activate(  );
hNETObj.FullName;
end 

function hController = controller(  )
hController = mlreportgen.utils.internal.WordController.instance(  );
end 
end 

methods ( Access = private )
function updateNETObjFields( this, netobjFields )

nBefore = executeWithRetries( this, @(  )netobjFields.Count );
executeWithRetries( this, @(  )netobjFields.Update(  ) );
nAfter = executeWithRetries( this, @(  )netobjFields.Count );

while ( ( nBefore > 0 ) && ( nAfter > 0 ) && ( nBefore < nAfter ) )
nBefore = executeWithRetries( this, @(  )netobjFields.Count );

executeWithRetries( this, @(  )netobjFields.Update(  ) );
nAfter = executeWithRetries( this, @(  )netobjFields.Count );
end 
end 

function makeDirty( this )
hNETObj = netobj( this );
executeWithRetries( this, @(  )dirtyNETObj( hNETObj ) );
flush( this );
end 

function repaginate( this )
hNETObj = netobj( this );
executeWithRetries( this, @(  )hNETObj.Repaginate(  ) );
flush( this );
end 

function updateFields( this )
hNETObj = netobj( this );
hFields = executeWithRetries( this, @(  )hNETObj.Fields );
nFields = executeWithRetries( this, @(  )hFields.Count );
if ( nFields > 0 )
executeWithRetries( this, @(  )updateNETObjFields( this, hFields ) );
flush( this );
end 
end 

function updateHeadersAndFooters( this )
ePrimary = Microsoft.Office.Interop.Word.WdHeaderFooterIndex.wdHeaderFooterPrimary;
eFirstPage = Microsoft.Office.Interop.Word.WdHeaderFooterIndex.wdHeaderFooterFirstPage;
eEvenPages = Microsoft.Office.Interop.Word.WdHeaderFooterIndex.wdHeaderFooterEvenPages;

hNETObj = netobj( this );
hSections = executeWithRetries( this, @(  )hNETObj.Sections );
nSections = executeWithRetries( this, @(  )hSections.Count );
for i = 1:nSections
hSection = executeWithRetries( this, @(  )hSections.Item( i ) );

hSectionFields = executeWithRetries( this, @(  )hSection.Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hSectionFields ) );


hHeaders = executeWithRetries( this, @(  )hSection.Headers );

hHeaderPrimaryFields = executeWithRetries( this, @(  )hHeaders.Item( ePrimary ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hHeaderPrimaryFields ) );

hHeaderFirstPageFields = executeWithRetries( this, @(  )hHeaders.Item( eFirstPage ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hHeaderFirstPageFields ) );

hHeaderEvenPagesFields = executeWithRetries( this, @(  )hHeaders.Item( eEvenPages ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hHeaderEvenPagesFields ) );


hFooters = executeWithRetries( this, @(  )hSection.Footers );

hFooterPrimaryFields = executeWithRetries( this, @(  )hFooters.Item( ePrimary ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hFooterPrimaryFields ) );

hFooterFirstPageFields = executeWithRetries( this, @(  )hFooters.Item( eFirstPage ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hFooterFirstPageFields ) );

hFooterEvenPagesFields = executeWithRetries( this, @(  )hFooters.Item( eEvenPages ).Range.Fields );
executeWithRetries( this, @(  )updateNETObjFields( this, hFooterEvenPagesFields ) );
end 
flush( this );
end 

function updateTableOfContents( this )
hNETObj = netobj( this );
hTOCs = executeWithRetries( this, @(  )hNETObj.TablesOfContents );
n = executeWithRetries( this, @(  )hTOCs.Count );
for i = 1:n
item = executeWithRetries( this, @(  )hTOCs.Item( i ) );
executeWithRetries( this, @(  )item.Update(  ) );
end 
updatedTOC = ( n > 0 );
if updatedTOC
flush( this );
end 
end 

function updateTableOfFigures( this )
hNETObj = netobj( this );
hTOFs = executeWithRetries( this, @(  )hNETObj.TablesOfFigures );
n = executeWithRetries( this, @(  )hTOFs.Count );
for i = 1:n
item = executeWithRetries( this, @(  )hTOFs.Item( i ) );
executeWithRetries( this, @(  )item.Update(  ) );
end 
updatedTOF = ( n > 0 );
if updatedTOF
flush( this );
end 
end 

function updateOLEObjects( this )
hNETObj = netobj( this );
hShapes = executeWithRetries( this, @(  )hNETObj.InlineShapes );
n = executeWithRetries( this, @(  )hShapes.Count );
for i = 1:n
item = executeWithRetries( this, @(  )hShapes.Item( i ) );
if strcmp( item.Type, "wdInlineShapeEmbeddedOLEObject" )
oleFormat = executeWithRetries( this, @(  )item.OLEFormat );
if ~isempty( oleFormat )
executeWithRetries( this, @(  )oleFormat.ConvertTo( oleFormat.ProgID ) );
end 
end 
end 
if ( n > 0 )
flush( this );
end 
end 

function scopedHide = expandSubdocuments( this, options )
R36
this
options.Show = true;
end 

scopedHide = [  ];
hNETObj = netobj( this );
hSubdocs = executeWithRetries( this, @(  )hNETObj.Subdocuments );
n = executeWithRetries( this, @(  )hSubdocs.Count );
if ( n > 0 )
if options.Show

scopedHide = showWithCleanup( this );
end 
executeWithRetries( this, @(  )expandSubdocNETObj( hSubdocs ) );
end 
flush( this );
end 

function outputFullPath = saveAs( this, wdFormat, fExt, varargin )
if isempty( varargin )
[ fPath, fName ] = fileparts( this.FileName );
outputFile = fullfile( fPath, fName + fExt );
else 
outputFile = varargin{ 1 };
end 
outputFullPath = string( mlreportgen.utils.internal.canonicalPath( outputFile ) );

if strcmp( this.FileName, outputFullPath )
save( this );
end 

hNETObj = netobj( this );
hasSaveAsMethod = executeWithRetries( this, @(  )ismethod( hNETObj, "SaveAs" ) );
if hasSaveAsMethod
executeWithRetries( this, @(  )hNETObj.SaveAs(  ...
outputFullPath,  ...
wdFormat ) );
else 
executeWithRetries( this, @(  )hNETObj.SaveAs2(  ...
outputFullPath,  ...
wdFormat ) );
end 
flush( this );
end 

function scopeCleanup = showWhiteSpaceBetweenPage( this )
hNETObj = netobj( this );
origVal = executeWithRetries( this,  ...
@(  )setShowWhiteSpaceBetweenPage( hNETObj, true ) );
scopeCleanup = onCleanup( @(  )executeWithRetries( this,  ...
@(  )setShowWhiteSpaceBetweenPage( hNETObj, origVal ) ) );
end 

function scopeHide = showWithCleanup( this )
scopeHide = [  ];
if ( ~isVisible( this ) )
show( this );
scopedHide = onCleanup( @(  )hide( this ) );
end 
end 
end 
end 

function origVal = setShowWhiteSpaceBetweenPage( hNETObj, newVal )
hViewNETObj = hNETObj.Application.Windows.Item( 1 ).View;
origVal = hViewNETObj.DisplayPageBoundaries;
hViewNETObj.DisplayPageBoundaries = newVal;
end 

function hNETObj = findDocNETObj( hDocs, fullFilePath )
hNETObj = [  ];
nDocs = hDocs.Count;
for i = 1:nDocs
hDoc = hDocs.Item( i );
if strcmpi( string( hDoc.FullName ), fullFilePath )
hNETObj = hDoc;
break ;
end 
end 
end 

function hNETObj = openDocNETObj( hDocs, fullFilePath )

f = Microsoft.Office.Core.MsoTriState.msoFalse;
t = Microsoft.Office.Core.MsoTriState.msoTrue;
unset = System.Reflection.Missing.Value;
nDocs = hDocs.Count;

hNETObj = hDocs.Open( fullFilePath,  ...
f,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
unset,  ...
f,  ...
unset,  ...
t );

success = mlreportgen.utils.internal.waitFor( @(  )( hDocs.Count == ( nDocs + 1 ) ) );
if ~success
error( message( "mlreportgen:utils:error:timedOutOpenFile", fullFilePath ) );
end 
end 


function showNETObj( hNETObj )
hNETObj.Activate(  );
hWin = hNETObj.ActiveWindow;
hWin.Visible = true;
hWin.Activate(  );
mlreportgen.utils.internal.waitFor( @(  )hWin.Visible );

hApp = hNETObj.Application;
if ~hApp.Visible


hApp.Visible = true;
hApp.Activate(  );
mlreportgen.utils.internal.waitFor( @(  )hApp.Visible );
end 

eMinimize = Microsoft.Office.Interop.Word.WdWindowState.wdWindowStateMinimize;
eNormal = Microsoft.Office.Interop.Word.WdWindowState.wdWindowStateNormal;
if ( hWin.WindowState == eMinimize )
hWin.WindowState = eNormal;
end 


try 
hwnd = hWin.Hwnd;
catch 
hwnd = [  ];
end 

if ~isempty( hwnd )
mlreportgen.utils.internal.bringWindowToFront( hwnd );
end 
end 

function hideNETObj( hNETObj )
hWin = hNETObj.ActiveWindow;
hWin.Visible = false;
mlreportgen.utils.internal.waitFor( @(  )~hWin.Visible );
end 

function tf = closeNETObj( hNETObj, closeFlag )
tf = false;
if ( ~closeFlag || hNETObj.Saved )
hNETObj.Activate(  );
hNETObj.Close( Microsoft.Office.Interop.Word.WdSaveOptions.wdDoNotSaveChanges );
tf = true;
end 
end 

function hideAppNETObj( hApp )
hApp.Visible = false;
end 

function dirtyNETObj( hNETObj )
hNETObj.Saved = false;
end 

function expandSubdocNETObj( hSubdocs )
hSubdocs.Expanded = true;
end 

function unlinkSubdocNETObj( hNETObj )
hSubdocs = hNETObj.Subdocuments;
nSubdocs = hSubdocs.Count;
for i = nSubdocs: - 1:1
hSubdocs.Item( i ).Delete(  );
mlreportgen.utils.internal.waitFor(  ...
@(  )hSubdocs.Count < ( i - 1 ) );
end 
end 

function setMapPaperSize( hNETObj, value )
napp = hNETObj.Application;
napp.Options.MapPaperSize = value;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxjW8Yr.p.
% Please follow local copyright laws when handling this file.

