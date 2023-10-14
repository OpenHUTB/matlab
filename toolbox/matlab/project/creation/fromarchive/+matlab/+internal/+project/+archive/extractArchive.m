function [ topLevelProjectRoot, project ] = extractArchive( archive, options )

arguments
    archive( 1, 1 )string{ mustBeNonzeroLengthText }
    options.ExtractionFolder( 1, 1 )string = missing
    options.ExtractToSubFolder( 1, 1 )logical = true
    options.Interactive( 1, 1 )logical = false
    options.OpenAfterExtraction( 1, 1 )logical = true
end

if nargout > 0
    topLevelProjectRoot = missing;
end
project = matlab.project.Project.empty( 1, 0 );

try
    i_validateType( archive );
catch ME
    i_handleError( ME, options.Interactive );
    return ;
end

if i_userAbortsBecauseOfMissingProducts( archive, options.Interactive )
    return ;
end

[ extractionFolder, defaulted ] = i_getExtractionFolder( options.ExtractionFolder, options.Interactive );
if isnumeric( extractionFolder )
    return ;
else
    extractionFolder = string( extractionFolder );
end

if options.ExtractToSubFolder || defaulted
    extractionFolder = i_getNotExistingDirBasedOnArchiveName( extractionFolder, archive );
end

try
    root = i_extract( archive, extractionFolder );
catch ME
    i_handleError( ME, options.Interactive );
    return ;
end

if nargout > 0
    topLevelProjectRoot = root;
end
if options.OpenAfterExtraction
    project = matlab.project.loadProject( root );
end
end

function result = i_compareExtension( varargin )
ignoreCase = ispc;

if ignoreCase
    result = strcmpi( varargin{ : } );
else
    result = strcmp( varargin{ : } );
end
end

function topLevelRoot = i_extract( archive, extractionFolder )
import matlab.internal.project.archive.extractMlproj;
import matlab.internal.project.archive.extractZip;
[ ~, ~, extension ] = fileparts( archive );
if i_compareExtension( extension, ".mlproj" )
    topLevelRoot = extractMlproj( archive, extractionFolder );
else
    topLevelRoot = extractZip( archive, extractionFolder );
end
end

function missingProducts = i_findMissingProducts( archive )
import matlab.internal.project.packaging.PackageReader
import template_core.internal.request.identifyProducts;
reader = PackageReader( archive );
reqProducts = reader.RequiredProducts;
missingProducts = identifyProducts( reqProducts{ : } );
end

function [ extractionFolder, defaulted ] = i_getExtractionFolder( extractionFolder, interactive )
import matlab.internal.project.creation.getDefaultFolder;
defaulted = false;
if ~ismissing( extractionFolder ) && "" ~= extractionFolder
    return ;
end

extractionFolder = getDefaultFolder(  );
if interactive
    title = string( i_getMessage( "ExtractProjectFileChooserTitle" ) );
    extractionFolder = uigetdir( extractionFolder, title );
else
    defaulted = true;
end
end

function msg = i_getMessage( resource, varargin )
msg = message( "MATLAB:project:archive:" + resource, varargin{ : } );
end

function extractionFolder = i_getNotExistingDirBasedOnArchiveName( baseExtractionFolder, archive )
[ ~, archiveName, ~ ] = fileparts( archive );
n = 1;
extractionFolder = fullfile( baseExtractionFolder, archiveName );
while exist( extractionFolder, "file" )
    extractionFolder = fullfile( baseExtractionFolder, archiveName + n );
    n = n + 1;
end
end

function i_handleError( ME, interactive )
if interactive
    errordlg( ME.message, string( i_getMessage( "ErrorExtractingTitle" ) ), "modal" );
else
    rethrow( ME );
end
end

function abort = i_showAlertDialog( products )
import matlab.internal.lang.capability.Capability;

title = string( i_getMessage( "MissingInstalledProductsUITitle" ) );
list = strjoin( "- " + { products.name }, newline );
msg = string( i_getMessage( "MissingInstalledProductsMessage", list ) );
continueAnyway = string( i_getMessage( "MissingInstalledProductsUIContinue" ) );
showAddonExplorer = string( i_getMessage( "MissingInstalledProductsUIAddonExplorer" ) );
cancel = string( i_getMessage( "MissingInstalledProductsUICancel" ) );

isLocal = Capability.isSupported( Capability.LocalClient );
if isLocal
    buttons = { continueAnyway, showAddonExplorer, cancel };
else
    buttons = { continueAnyway, cancel };
end

res = questdlg( msg, title, buttons{ : }, continueAnyway );

switch res
    case continueAnyway
        abort = false;
    case showAddonExplorer
        abort = true;
        template_core.internal.request.openAddonExplorerFor( { products.basecode } );
    otherwise
        abort = true;
end
end

function i_showMissingProductWarning( products )
listElemFormat = "<a href=""matlab:template_core.internal.request.openAddonExplorerFor('%s')"">%s</a>";
listElems = arrayfun( @( p )sprintf( listElemFormat, p.basecode, p.name ), products );
list = strjoin( "- " + listElems, newline );
warning( i_getMessage( "MissingInstalledProductsMessage", list ) );
end

function abort = i_userAbortsBecauseOfMissingProducts( archive, interactive )
abort = false;
[ ~, ~, extension ] = fileparts( archive );
if ~i_compareExtension( extension, ".mlproj" )
    return ;
end

products = i_findMissingProducts( archive );

if isempty( products )
    return ;
end

if interactive
    abort = i_showAlertDialog( products );
else
    i_showMissingProductWarning( products );
end
end

function i_validateType( archive )
[ ~, ~, extension ] = fileparts( archive );
if ~any( i_compareExtension( extension, [ ".mlproj", ".zip" ] ) )
    error( i_getMessage( "UnsupportedExtension", extension ) );
end
if i_compareExtension( extension, ".mlproj" )
    matlab.internal.project.archive.validateMlproj( archive );
end
end

