classdef PortInterfaceUsageChecker < handle












properties 
modelName;
ddConn = '';
ddFileSpec = '';
end 






properties ( Constant )
FIX = 'fix_broken_interface_resolutions';
CLEAR = 'clear_broken_interface_resolutions';
REPORT = 'report_broken_interface_resolutions';
end 

methods 
function this = PortInterfaceUsageChecker( modelName )
R36
modelName( 1, : )char
end 
this.modelName = modelName;


try 
this.ddConn = Simulink.data.dictionary.open( get_param( this.modelName, 'DataDictionary' ) );
this.ddFileSpec = this.ddConn.filepath;
catch 
end 
end 

function archPorts = getArchPortsFromPortQualifiedNames( this, portQualifiedPaths )%#ok<INUSL>


archPorts = [  ];
for i = 1:numel( portQualifiedPaths )
pathData = split( portQualifiedPaths{ i }, '/' );
owner = join( pathData( 1:end  - 1 ), '/' );
ownerHdl = get_param( owner{ 1 }, 'handle' );
if strcmp( get_param( ownerHdl, 'type' ), 'block_diagram' ) && strcmp( get_param( ownerHdl, 'SimulinkSubDomain' ), 'Simulink' )

portName = pathData{ end  };
bepPorts = find_system( get_param( ownerHdl, 'Name' ), 'SearchDepth', 1, 'PortName', portName );
if ~isempty( bepPorts )
port = systemcomposer.utils.getArchitecturePeer( get_param( bepPorts{ 1 }, 'Handle' ) );
end 
else 
compOrArch = systemcomposer.utils.getArchitecturePeer( ownerHdl );
port = compOrArch.getPort( pathData{ end  } );
if isa( port, 'systemcomposer.architecture.model.design.ComponentPort' )
port = port.getArchitecturePort;
end 
end 
archPorts = [ archPorts, port ];%#ok<AGROW>
end 
end 

function archPorts = getArchPortsAcrossModelHierarchy( this )

zcMdl = get_param( this.modelName, 'SystemComposerModel' );
zcMdlImpl = zcMdl.getImpl;
rootArch = zcMdlImpl.getRootArchitecture;
archPorts = rootArch.getPortsAcrossHierarchy;
end 

function applyAction( this, archPorts, action )

if strcmp( action, this.FIX )
this.fixBrokenAssociationAction( archPorts );
elseif strcmp( action, this.REPORT )
this.reportBrokenAssociationAction( archPorts );
elseif strcmp( action, this.CLEAR )
this.clearBrokenAssociationAction( archPorts );
else 
error( message( 'SystemArchitecture:zcFixitWorkflows:UnsupportedAction' ) );
end 
end 

function reportBrokenAssociationAction( this, archPorts )



if ~isempty( archPorts )
[ ~, allErrors ] = this.gatherBrokenAssociationUsages( archPorts );
if ~isempty( allErrors )
ME = MSLException( 'SystemComposer:zcFixitWorkflows:InterfaceResolutionFailuresDetected', allErrors{ 1 } );
throw( ME );
end 
else 
error( message( 'SystemArchitecture:zcFixitWorkflows:NoPortsSpecified' ) );
end 
end 

function fixBrokenAssociationAction( this, archPorts )




if isempty( this.ddFileSpec )
error( message( 'SystemArchitecture:zcFixitWorkflows:NoDictionaryAvailable' ) );
end 

brokenUsages = this.gatherBrokenAssociationUsages( archPorts );
brokenPorts = brokenUsages.ports;
updatedSLDDs = {  };

try 
if ~isempty( brokenPorts )
zcMdl = get_param( this.modelName, 'SystemComposerModel' );
zcMdlImpl = zcMdl.getImpl;
txn = mf.zero.getModel( zcMdlImpl ).beginTransaction(  );
for idx = 1:numel( brokenPorts )
port = brokenPorts( idx );
pi = systemcomposer.internal.resolvePortInterfaceAssociationUsingName( port, this.ddFileSpec );
if ~isempty( pi )
updatedSLDDs = [ updatedSLDDs, pi.getCatalog.getStorageSource ];%#ok<AGROW> 
end 
end 
txn.commit(  );


[ ~, ddName, ~ ] = fileparts( this.ddFileSpec );
updatedSLDDs = [ updatedSLDDs, ddName ];
updatedSLDDs = unique( updatedSLDDs );
for i = 1:numel( updatedSLDDs )
updatedSLDDConn = Simulink.data.dictionary.open( [ updatedSLDDs{ i }, '.sldd' ] );
this.dirtyAndOptionallyResaveDD( updatedSLDDConn );
end 
else 
error( message( 'SystemArchitecture:zcFixitWorkflows:NoPortsSpecified' ) );
end 
catch ME
baseException = MSLException( 'SystemArchitecture:zcFixitWorkflows:FailedToApplyAction' );
baseException = baseException.addCause( ME );
throw( baseException );
end 
end 

function clearBrokenAssociationAction( this, archPorts )



brokenUsages = this.gatherBrokenAssociationUsages( archPorts );
brokenPorts = brokenUsages.ports;
brokenElems = brokenUsages.elements;

try 
if ~isempty( brokenPorts ) || ~isempty( brokenElems )
for idx = 1:numel( brokenPorts )
port = brokenPorts( idx );
portWrapper = systemcomposer.internal.getWrapperForImpl( port );
portWrapper.setInterface( '' );
end 

for idx = 1:numel( brokenElems )
elem = brokenElems( idx );
elemWrapper = systemcomposer.internal.getWrapperForImpl( elem );
elemWrapper.createOwnedType( 'DataType', 'double' );
end 
else 
error( message( 'SystemArchitecture:zcFixitWorkflows:NoPortsSpecified' ) );
end 
catch ME
baseException = MSLException( 'SystemArchitecture:zcFixitWorkflows:FailedToApplyAction' );
baseException = baseException.addCause( ME );
throw( baseException );
end 
end 

function [ brokenUsages, vargout ] = gatherBrokenAssociationUsages( ~, ports )


brokenPorts = [  ];
brokenElems = [  ];
reportErrors = nargout > 1;
if reportErrors
allErrors = [  ];
end 

function addErrorToList( exception )
if reportErrors
if isempty( allErrors )
allErrors = [ '\n', exception.message ];
else 
allErrors = [ allErrors, '\n', exception.message ];
end 
end 
end 

for i = 1:numel( ports )
port = ports( i );
try 
intrf = port.getPortInterface(  );
if ( ~isempty( intrf ) && intrf.isAnonymous && isa( intrf, 'systemcomposer.architecture.model.interface.CompositeDataInterface' ) )

elems = intrf.getElements;
for j = 1:numel( elems )
try 
elems( j ).getTypeAsInterface(  );
catch 
brokenElems = [ brokenElems;elems( j ) ];%#ok<AGROW> 
end 
end 
end 
catch ex
brokenPorts = [ brokenPorts;port ];%#ok<AGROW>
addErrorToList( ex )
end 
end 
brokenUsages.ports = brokenPorts;
brokenUsages.elements = brokenElems;
if reportErrors
vargout( : ) = { allErrors };
end 
end 

function dirtyAndOptionallyResaveDD( this, ddConn )%#ok<INUSL> 




if ( ~isempty( ddConn ) && ~ddConn.HasUnsavedChanges(  ) )
Simulink.SystemArchitecture.internal.DictionaryRegistry.DirtyDD( ddConn.filepath );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpHIElVZ.p.
% Please follow local copyright laws when handling this file.

