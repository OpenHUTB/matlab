classdef ( Hidden )HierarchyService

























methods ( Static )
function tf = isValid( hid )




hs = slreportgen.utils.HierarchyService;
tf = hs.isValidDiagram( hid ) || hs.isValidElement( hid );
end 

function tf = isTopLevel( hid )





tf = ~isempty( hid ) && GLUE2.HierarchyService.isTopLevel( hid );
end 

function tf = isDiagram( hid )





tf = ~isempty( hid ) && GLUE2.HierarchyService.isDiagram( hid );
end 

function tf = isElement( hid )






tf = ~isempty( hid ) && GLUE2.HierarchyService.isElement( hid );
end 

function tf = isImplDiagram( hid )






hs = slreportgen.utils.HierarchyService;
tf = slreportgen.utils.isTruthTable( hid ) ...
 && hs.isDiagram( hid );
end 

function out = getDomain( hid )




if ~isempty( hid )
out = GLUE2.HierarchyService.getDomainName( hid );
else 
out = '';
end 
end 

function out = getTopLevel( hid )





if ~isempty( hid )
out = GLUE2.HierarchyService.getTopLevel( hid );
else 
out = GLUE2.HierarchyId.empty(  );
end 
end 

function p = getParent( hid )





p = GLUE2.HierarchyId.empty(  );
if ~isempty( hid )
p = GLUE2.HierarchyService.getParent( hid );
if ~GLUE2.HierarchyService.isValid( p )
p = GLUE2.HierarchyId.empty(  );
end 
end 
end 

function c = getChildren( hid, options )














R36
hid GLUE2.HierarchyId
options.LoadReferencedModels logical = false;
options.LoadLibraries logical = false;
end 

if ~isempty( hid )
if options.LoadLibraries || options.LoadReferencedModels
hs = slreportgen.utils.HierarchyService;
backingHandle = slreportgen.utils.getSlSfHandle( hid );
hs.loadBackingReferences( backingHandle,  ...
loadlibraries = options.LoadLibraries,  ...
LoadReferencedModels = options.LoadReferencedModels );
end 
ghs = GLUE2.HierarchyService;
c = ghs.getChildren( hid );
else 
c = GLUE2.HierarchyId.empty(  );
end 
end 

function dhid = getDiagramHID( obj )





hs = slreportgen.utils.HierarchyService;
dhid = GLUE2.HierarchyId.empty(  );
if isa( obj, 'GLUE2.HierarchyId' )
if hs.isElement( obj )
chids = hs.getChildren( obj, 'LoadReferencedModel', true );
if ~isempty( chids )
dhid = chids( 1 );
end 
else 
dhid = obj;
end 

else 
if ( ( ischar( obj ) || isstring( obj ) ) && ~slreportgen.utils.isSID( obj ) )
dhid = hs.getDiagramHIDFromPath( obj );
end 

if isempty( dhid )
backingHandle = slreportgen.utils.getSlSfHandle( obj );
dhid = hs.getDiagramHIDFromBackingHandle( backingHandle );
end 
end 
end 

function ehid = getElementHID( obj )





hs = slreportgen.utils.HierarchyService;
if isa( obj, 'GLUE2.HierarchyId' )
if hs.isDiagram( obj )


ehid = hs.getParent( obj );
else 
ehid = obj;
end 

elseif ( ( ischar( obj ) || isstring( obj ) ) && ~slreportgen.utils.isSID( obj ) )
dhid = hs.getDiagramHIDFromPath( obj );
if ~isempty( dhid )
ehid = hs.getParent( dhid );
else 
backingHandle = slreportgen.utils.getSlSfHandle( obj );
ehid = hs.getElementHIDFromBackingHandle( backingHandle );
end 

else 
backingHandle = slreportgen.utils.getSlSfHandle( obj );
ehid = hs.getElementHIDFromBackingHandle( backingHandle );
end 
end 

function hid = getHIDWithParent( obj, parentHID )



R36
obj
parentHID( 1, 1 )GLUE2.HierarchyId
end 

backingHandle = slreportgen.utils.getSlSfHandle( obj );
if isa( backingHandle, 'Stateflow.Object' )
hid = StateflowDI.HierarchyServiceUtils.getHIDWithParent( backingHandle.Id, parentHID );
else 
hid = SLM3I.HierarchyServiceUtils.getHIDWithParent( backingHandle, parentHID );
end 
end 

function hid = getHIDFromStringID( id )





lhids = textscan( id, '%s', 'delimiter', '/' );
lhids = lhids{ 1 };
nlvls = length( lhids );

if ( nlvls > 0 )
sid = lhids{ 1 }( 1:end  - 2 );
hid = slreportgen.utils.HierarchyService.getDiagramHID( sid );
end 

ghs = GLUE2.HierarchyService;
sfhsu = StateflowDI.HierarchyServiceUtils;
slhsu = SLM3I.HierarchyServiceUtils;

for i = 2:nlvls
if ghs.isElement( hid )
c = ghs.getChildren( hid );
hid = c( 1 );
else 
sid = lhids{ i }( 1:end  - 2 );
backingHandle = Simulink.ID.getHandle( sid );
if isa( backingHandle, 'Stateflow.Object' )
hid = sfhsu.getHIDWithParent( backingHandle.Id, hid );
else 
hid = slhsu.getHIDWithParent( backingHandle, hid );
end 
end 
end 
end 

function id = getStringID( inHID )












ghs = GLUE2.HierarchyService;
id = '';
hid = inHID;
while ~isempty( hid ) && ghs.isValid( hid )
if ghs.isDiagram( hid )
suffix = 'd';
else 
suffix = 'e';
end 

backingH = slreportgen.utils.getSlSfHandle( hid );
sid = Simulink.ID.getSID( backingH );

if isempty( id )
id = [ sid, ':', suffix ];
else 
id = [ sid, ':', suffix, '/', id ];%#ok
end 

hid = ghs.getParent( hid );
end 
end 

function out = getPath( inHID )










hs = slreportgen.utils.HierarchyService;
out = '';

hid = inHID;
while ~isempty( hid )
if ( hs.isElement( hid ) || hs.isTopLevel( hid ) )
name = hs.getName( hid );
name = regexprep( name, '/', '//' );
name = regexprep( name, '\s', ' ' );
out = [ name, '/', out ];%#ok
end 
hid = hs.getParent( hid );
end 

if ~isempty( out )
out( end  ) = [  ];
end 
end 

function pHID = getParentDiagramHID( hid )






hs = slreportgen.utils.HierarchyService;
pHID = hs.getParent( hid );
if hs.isElement( pHID )
pHID = hs.getParent( pHID );
end 
end 

function name = getName( hid )





hs = slreportgen.utils.HierarchyService;
if ~hs.isTopLevel( hid )
if hs.isElement( hid )
ehid = hid;
else 
ehid = hs.getElementHID( hid );
end 

backingH = slreportgen.utils.getSlSfHandle( ehid );
if isnumeric( backingH )
backingName = get_param( backingH, 'Name' );
if slreportgen.utils.isModelReferenceBlock( backingH )
name = sprintf( '%s (%s)', backingName, get_param( backingH, 'ModelName' ) );
elseif slreportgen.utils.isSubsystemReferenceBlock( backingH )
name = sprintf( '%s (%s)', backingName, get_param( backingH, 'ReferencedSubsystem' ) );
elseif slreportgen.utils.isConfigurableSubsystemBlock( backingH )
name = sprintf( '%s (%s)', get_param( backingH, 'BlockChoice' ), backingName );
else 
name = backingName;
end 
else 
name = get( backingH, 'Name' );
end 

else 
backingH = slreportgen.utils.getSlSfHandle( hid );
if isnumeric( backingH )
name = get_param( backingH, 'Name' );
else 
name = get( backingH, 'Name' );
end 
end 
end 

function sid = getSID( hid )





if ~isempty( hid )

hs = slreportgen.utils.HierarchyService;
dhid = hs.getDiagramHID( hid );


objH = slreportgen.utils.getSlSfHandle( dhid );

if isa( objH, "Stateflow.Object" )

slBackingH = SLM3I.SLCommonDomain.getSLHandleForHID( dhid );


sid = Simulink.ID.getStateflowSID( objH, slBackingH );
else 
sid = Simulink.ID.getSID( objH );
end 
else 
sid = '';
end 
end 
end 

methods ( Static, Access = private )
function dhid = getDiagramHIDFromBackingHandle( backingHandle )
hs = slreportgen.utils.HierarchyService;
if isa( backingHandle, 'Stateflow.Object' )
dhid = GLUE2.HierarchyId(  );
if ( isa( backingHandle, 'Stateflow.Chart' ) || ~isempty( backingHandle.down ) )
dhid = StateflowDI.HierarchyServiceUtils.getDefaultHIDForDiagram( backingHandle.Id );
end 

if ~hs.isValidDiagram( dhid )
ehid = hs.getElementHIDFromBackingHandle( backingHandle );
if hs.isValidElement( ehid )
dhid = hs.getDiagramHID( ehid );
end 
end 
else 
obj = get_param( backingHandle, 'Object' );
if ( isa( obj, 'Simulink.SubSystem' ) || isa( obj, 'Simulink.BlockDiagram' ) )
dhid = SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph( backingHandle );
else 
if slreportgen.utils.isModelReferenceBlock( backingHandle )
hs.loadBackingReferences( backingHandle, 'LoadReferencedModels', true );
end 

ehid = hs.getElementHIDFromBackingHandle( backingHandle );
dhid = hs.getDiagramHID( ehid );
end 
end 








end 

function ehid = getElementHIDFromBackingHandle( backingHandle )
if isa( backingHandle, 'Stateflow.Chart' )
blockH = sfprivate( 'chart2block', backingHandle.Id );
ehid = SLM3I.HierarchyServiceUtils.getDefaultHIDForBlock( blockH );

elseif isa( backingHandle, 'Stateflow.Object' )
ehid = StateflowDI.HierarchyServiceUtils.getDefaultHIDForElement( backingHandle.Id );

else 
ehid = SLM3I.HierarchyServiceUtils.getDefaultHIDForBlock( backingHandle );
end 









end 

function dhid = getDiagramHIDFromPath( inPath )

hs = slreportgen.utils.HierarchyService;


pathSplits = slreportgen.utils.pathSplit( inPath );
pathParts = pathSplits( 1 );
dhid = hs.getDiagramHIDFromBackingHandle( get_param( pathParts, 'Handle' ) );


nPathSplits = numel( pathSplits );
for i = 2:nPathSplits
pathName = pathSplits{ i };


cehids = hs.getChildren( dhid );
nCehids = numel( cehids );
ehid = GLUE2.HierarchyId.empty(  );

for j = 1:nCehids
cehid = cehids( j );

hidPathName = hs.getName( cehid );

hidPathName = regexprep( hidPathName, '/', '//' );
hidPathName = regexprep( hidPathName, '\s', ' ' );
if strcmp( pathName, hidPathName )
ehid = cehid;
break ;
end 
end 

if ~isempty( ehid )

cdhids = hs.getChildren( ehid );
dhid = cdhids( 1 );
else 
dhid = GLUE2.HierarchyId.empty(  );
break ;
end 
end 








end 

function tf = isValidElement( ehid )
persistent FILTER;

if isempty( FILTER )
FILTER = SLM3I.SLTreeFilter(  );
FILTER.ShowSystemsWithMaskedParameters = true;
FILTER.ShowReferencedModels = true;
FILTER.ShowUserLinks = true;
FILTER.ShowMathworksLinks = true;
end 

ghs = GLUE2.HierarchyService;
tf = ~isempty( ehid ) && ( ghs.isValid( ehid ) && ghs.isElement( ehid ) ) && FILTER.keepHid( ehid );
end 

function tf = isValidDiagram( dhid )
ghs = GLUE2.HierarchyService;

if ( ~isempty( dhid ) && ghs.isValid( dhid ) && ghs.isDiagram( dhid ) )
if ghs.isTopLevel( dhid )
tf = true;
else 
ehid = ghs.getParent( dhid );
tf = slreportgen.utils.HierarchyService.isValidElement( ehid );
end 
else 
tf = false;
end 
end 

function loadBackingReferences( backingHandle, options )
R36
backingHandle
options.LoadReferencedModels logical = false;
options.LoadLibraries logical = false;
end 

if ( options.LoadReferencedModels && slreportgen.utils.isModelReferenceBlock( backingHandle ) )
model = get_param( backingHandle, 'ModelName' );
load_system( model );
end 

if options.LoadLibraries
r = slroot(  );
if r.isValidSlObject( backingHandle )


libdata = libinfo( backingHandle,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all' );

n = numel( libdata );
for i = 1:n
try 
load_system( libdata( i ).Library );
catch ME
warning( ME.identifier, '%s', ME.message );
end 
end 
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKyKYhs.p.
% Please follow local copyright laws when handling this file.

