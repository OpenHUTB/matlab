


























































































































































































classdef LinkSet < slreq.internal.BaseSet

properties ( Dependent )
Description
end 

properties ( Dependent, GetAccess = public, SetAccess = private )
Filename
Artifact
Domain
Revision
Dirty
CustomAttributeNames
end 


methods 

function this = LinkSet( dataObject )
this.dataObject = dataObject;
end 

function name = get.Filename( this )
name = this.dataObject.filepath;
end 

function value = get.Artifact( this )
value = this.dataObject.artifact;
end 

function type = get.Domain( this )
type = this.dataObject.domain;
end 

function dirty = get.Dirty( this )
dirty = this.dataObject.dirty;
end 

function value = get.Revision( this )
value = this.dataObject.revision;
end 

function names = get.CustomAttributeNames( this )

names = this.dataObject.CustomAttributeNames;
end 

function value = get.Description( this )
value = this.dataObject.description;
end 

function set.Description( this, value )
value = convertStringsToChars( value );
this.dataObject.description = value;
end 

function result = save( this, varargin )
this.errorIfVectorOperation(  )
if isempty( varargin )
result = this.dataObject.save(  );
else 
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
result = this.dataObject.save( varargin{ : } );
end 
end 

function count = redirectLinksToImportedReqs( this, reqSet, showInfo )
this.errorIfVectorOperation(  )
if isa( reqSet, 'slreq.ReqSet' )
reqSet = reqSet.dataObject;
end 
if nargin < 3
showInfo = false;
end 
count = this.dataObject.redirectLinksToImportedContent( reqSet, showInfo );
end 

function result = sources( this )
this.errorIfVectorOperation(  )
linkedItems = this.dataObject.getLinkedItems(  );
if isempty( linkedItems )
result = {  };
else 
result = slreq.utils.resolveSrc( linkedItems );
end 
end 

function result = getLinks( this )
this.errorIfVectorOperation(  );
dataLinks = this.dataObject.getAllLinks(  );
result = slreq.utils.wrapDataObjects( dataLinks );
end 

function result = find( this, varargin )
this.errorIfVectorOperation(  );



if ~( isempty( varargin ) ||  ...
( numel( varargin ) == 2 && strcmpi( varargin{ 1 }, 'type' ) ) )
result = this.slreqFind( varargin{ : } );
return ;
end 

try 
dataLinks = this.dataObject.getAllLinks(  );
resultDataLink = slreq.utils.filterByProperties( dataLinks, varargin{ : } );
result = slreq.utils.wrapDataObjects( resultDataLink );
catch ex



throwAsCaller( ex );
end 
end 

function count = updateDocUri( this, origPath, newPath )
this.errorIfVectorOperation(  )
count = this.dataObject.updateDocUri( origPath, newPath );
end 

function updateRegisteredReqSets( this )
this.errorIfVectorOperation(  )
this.dataObject.updateRegisteredReqSets( true );
end 

function success = exportToVersion( this, targetFileName, release )
targetFileName = convertStringsToChars( targetFileName );
if slreq.utils.VersionHandler( release ).isSLReqVersion(  )
targetFileName = slreq.uri.getLinkSetFilePath( targetFileName, false );


if reqmgt( 'rmiFeature', 'IncArtExtInLinkFile' )
targetFileName = regexprep( targetFileName, '~\w*\.slmx$', '.slmx' );
end 
else 

[ ~, ~, fExt ] = fileparts( targetFileName );
if ~strcmp( fExt, '.req' )
targetFileName = [ targetFileName, '.req' ];
end 
end 

release = convertStringsToChars( release );
success = false;%#ok<NASGU>
try 
verObj = slreq.utils.VersionHandler( release );
catch ex
throwAsCaller( ex );
end 

if verObj.isSLReqVersion(  )

try 
success = this.dataObject.exportToPrevious( targetFileName, verObj.release );
catch ex
throwAsCaller( ex );
end 
elseif verObj.isDotReqVersion(  )

if ~strcmp( this.Domain, 'linktype_rmi_simulink' )
error( message( 'Slvnv:slreq:OnlySimulinkDomainCanBeExportToPrevious' ) )
end 
try 
slreq.utils.writeToDotReq( this.Artifact, targetFileName );
success = true;
catch ex
throwAsCaller( ex );
end 
else 
error( message( 'Slvnv:slreq:NoLinkSetExportToOldRelease' ) )
end 
end 

function reqSetNames = getRegisteredReqSets( this )
this.errorIfVectorOperation(  );
reqSetNames = this.dataObject.getRegisteredRequirementSets(  );
end 

function [ numChecked, numAdded, numRemoved ] = updateBacklinks( this, doRemoveUnmatched )
this.errorIfVectorOperation(  );
if nargin < 2
doRemoveUnmatched = false;
end 
cleanup = slreq.internal.TempFlags.changeFlag( 'BacklinksCleanupViaAPI', doRemoveUnmatched );%#ok<NASGU> 
[ numChecked, numAdded, numRemoved ] = this.dataObject.updateBacklinks(  );
end 


function linksWithChangedSource = getLinksWithChangedSource( this )


this.errorIfVectorOperation(  );
dataLinkSet = this.dataObject;

if dataLinkSet.changeStatus.isUndecided
ct = slreq.analysis.ChangeTracker.getInstance;
ct.refreshLinkSet( dataLinkSet )
end 

linkUuidsWithSrcFail = dataLinkSet.changedSource.keys;

linksWithChangedSource =  ...
slreq.utils.getLinksFromUUIDs( linkUuidsWithSrcFail );


end 


function linksWithChangedDestination = getLinksWithChangedDestination( this )


this.errorIfVectorOperation(  );
dataLinkSet = this.dataObject;

if dataLinkSet.changeStatus.isUndecided
ct = slreq.analysis.ChangeTracker.getInstance;
ct.refreshLinkSet( dataLinkSet )
end 
linkUuidsWithDstFail = dataLinkSet.changedDestination.keys;
linksWithChangedDestination =  ...
slreq.utils.getLinksFromUUIDs( linkUuidsWithDstFail );
end 


function clearChangeIssues( this, comment, target )










R36
this
comment = slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO;
target{ mustBeMember( target, [ "All", "Source", "Destination" ] ) } = "All";
end 

comment = convertStringsToChars( comment );
target = convertStringsToChars( target );
clearSrc = true;
clearDst = true;

if strcmp( target, 'Source' )
clearDst = false;
elseif strcmp( target, 'Destination' )
clearSrc = false;
end 

dataLinkSet = this.dataObject;

if dataLinkSet.changeStatus.isUndecided
ct = slreq.analysis.ChangeTracker.getInstance;
ct.refreshLinkSet( dataLinkSet )
end 


if clearDst
linkUuidsWithDstFail = dataLinkSet.changedDestination.keys;
linksWithChangedDestination =  ...
slreq.utils.getLinksFromUUIDs( linkUuidsWithDstFail );
linksWithChangedDestination.clearChangeIssues( comment, "Destination" )
end 

if clearSrc
linkUuidsWithSrcFail = dataLinkSet.changedSource.keys;

linksWithChangedSource =  ...
slreq.utils.getLinksFromUUIDs( linkUuidsWithSrcFail );

linksWithChangedSource.clearChangeIssues( comment, "Source" )
end 
end 

function importProfile( this, profileName )
this.errorIfVectorOperation(  );
if reqmgt( 'rmiFeature', 'SupportProfile' )
profileName = convertStringsToChars( profileName );
this.dataObject.importProfile( profileName );
end 
end 

function profiles = profiles( this )
this.errorIfVectorOperation(  );
prfs = this.dataObject.getAllProfiles(  );
profiles = prfs.toArray(  );
end 

function tf = removeProfile( this, profileName )
this.errorIfVectorOperation(  );
profileName = convertStringsToChars( profileName );
tf = this.dataObject.removeProfile( profileName );
end 

function textRange = getTextRange( this, varargin )
switch numel( varargin )
case 1
textId = '';
line = varargin{ 1 };
case 2
textId = varargin{ 1 };
line = varargin{ 2 };
otherwise 
error( message( 'Slvnv:reqmgt:rmi:WrongArgumentNumber' ) );
end 
textRange = this.getTextRanges( textId, line );
end 

function textRanges = getTextRanges( this, varargin )
switch numel( varargin )
case 0
textId = '';
lines = [  ];
case 1
if isnumeric( varargin{ 1 } )
textId = '';
lines = varargin{ 1 };
else 
textId = slreq.utils.validateTextItemId( varargin{ 1 } );
lines = [  ];
end 
case 2
textId = slreq.utils.validateTextItemId( varargin{ 1 } );
lines = varargin{ 2 };
otherwise 
error( message( 'Slvnv:reqmgt:rmi:WrongArgumentNumber' ) );
end 
textRanges = slreq.TextRange.empty(  );
dataTextRanges = this.dataObject.getTextRanges( textId, lines );
for i = 1:numel( dataTextRanges )
textRanges( end  + 1 ) = slreq.TextRange( dataTextRanges( i ) );%#ok<AGROW> 
end 
end 

function textRange = createTextRange( this, textId, lines )
if nargin < 3

lines = textId;
textId = '';
else 
textId = slreq.utils.validateTextItemId( textId );
end 
dataTextRange = this.dataObject.createTextRange( textId, lines );
textRange = slreq.TextRange( dataTextRange );
end 
end 

methods ( Access = private )
function result = slreqFind( this, varargin )

if mod( numel( varargin ), 2 ) > 0
error( message( 'Slvnv:reqmgt:rmi:WrongArgumentNumber' ) );
end 

if strcmpi( varargin{ 1 }, 'type' )
r = slreq.find( varargin{ : } );
else 
r = slreq.find( 'type', 'Link', varargin{ : } );
end 

if isempty( r )
result = [  ];
else 
result = slreq.Link.empty;
end 

for i = 1:length( r )
if r( i ).linkSet.dataObject == this.dataObject
result( end  + 1 ) = r( i );%#ok<AGROW> 
end 
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpU0GeFl.p.
% Please follow local copyright laws when handling this file.

