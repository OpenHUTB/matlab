function RTEInterfacePlugin( codeDescriptor, intFolder, buildInfo )




R36
codeDescriptor( 1, 1 )coder.codedescriptor.CodeDescriptor
intFolder( 1, : )char
buildInfo( 1, 1 )RTW.BuildInfo
end 

assert( isfolder( intFolder ) );
rteFileName = codeDescriptor.getServices(  ).getServicesHeaderFileName(  );
rteFileFullName = fullfile( intFolder, rteFileName );







fileExists = isfile( rteFileFullName );
if fileExists

tempFilename = tempname(  );
c = onCleanup( @(  )delete( tempFilename ) );
createdFilename = tempFilename;
else 
createdFilename = rteFileFullName;
end 
writer = rtw.connectivity.CodeWriter.create(  ...
'callCBeautifier', true,  ...
'filename', createdFilename );


writeBanner( writer, rteFileName );


writeIncludes( codeDescriptor, writer, rteFileName );



coder.internal.rte.writeActiveServicePrototypes( codeDescriptor, writer );


writeTrailer( writer, rteFileName );




writer.delete(  );



if fileExists
oldContent = fileread( rteFileFullName );
newContent = fileread( tempFilename );
if ~strcmp( oldContent, newContent )

copyfile( tempFilename, rteFileFullName );
end 
end 



updateBuildInfo( buildInfo, intFolder );

end 

function writeBanner( writer, rteFileName )
bannerFileName = strrep( rteFileName, '.', '_' );
bannerFileName = strrep( bannerFileName, ' ', '_' );
writer.wLine( '#ifndef RTW_HEADER_%s', bannerFileName );
writer.wLine( '#define RTW_HEADER_%s', bannerFileName );
end 

function writeIncludes( codeDescriptor, writer, RTEHeaderFile )
if isempty( codeDescriptor.getServices(  ) )
return ;
end 
headers = { 'rtwtypes.h' };


headers = getHeadersForDataTransfer( codeDescriptor, headers );


headers = getHeadersForRootIO( codeDescriptor, headers, RTEHeaderFile );


for j = 1:length( headers )
thisHeader = headers{ j };
thisHeader = strrep( thisHeader, '"', '' );
if ~isempty( thisHeader )
writer.wLine( [ '#include "', thisHeader, '"' ] );
end 
end 

function headers = getHeadersForDataTransfer( codeDescriptor, headers )
dataTransferService = codeDescriptor.getServices(  ).getServiceInterface(  ...
coder.descriptor.Services.DataTransfer );
if isempty( dataTransferService )
return ;
end 
for i = 1:dataTransferService.DataTransferElements.Size
elem = dataTransferService.DataTransferElements( i );

if elem.Functions.Size == 0
continue ;
end 

type = coder.internal.rte.builder.AccessMethodBuilder.getDataTransElemData( elem );
while type.isPointer || type.isMatrix
type = type.BaseType;
end 

assert( ~isempty( type.Identifier ) );
typeHeaders = getHeadersForSymbol(  ...
codeDescriptor.getFullComponentInterface(  ), type.Identifier );
if ~isempty( typeHeaders )
for typeHeaderIdx = 1:numel( typeHeaders )
typeHeader = typeHeaders{ typeHeaderIdx };
if ~isempty( typeHeader ) && ~ismember( typeHeader, headers )
headers{ end  + 1 } = typeHeader;
end 
end 
end 
end 
end 

function headers = getHeadersForRootIO( codeDescriptor, headers, RTEHeaderFile )
senderReceiverService = codeDescriptor.getServices(  ).getServiceInterface(  ...
coder.descriptor.Services.SenderReceiver );
inports = senderReceiverService.getReceiverInterfaces(  );
nInports = numel( inports );
outports = senderReceiverService.getSenderInterfaces(  );
ports = [ inports, outports ];
for portId = 1:numel( ports )
port = ports( portId );
if ~coder.internal.rte.util.isValidRootIOImplementation( port )
continue ;
end 
impls = coder.internal.rte.util.getImplementations( port );
for implId = 1:numel( impls )
impl = impls( implId );
inportHeaderFile = impl.Prototype.HeaderFile;
if ~strcmp( inportHeaderFile, RTEHeaderFile )
continue ;
end 
if portId <= nInports
isInport = true;
else 
isInport = false;
end 
baseType = getBaseTypeName( impl, isInport );
baseTypeHeaders = getHeadersForSymbol(  ...
codeDescriptor.getFullComponentInterface(  ), baseType );
for baseTypeHeaderIdx = 1:numel( baseTypeHeaders )
baseTypeHeader = baseTypeHeaders{ baseTypeHeaderIdx };
if ~ismember( baseTypeHeader, headers )
headers{ end  + 1 } = baseTypeHeader;
end 
end 
end 
end 

function baseTypeName = getBaseTypeName( impl, isInport )
ioAccessMode = impl.IOAccessMode;
prototype = impl.Prototype;

isValueModeToGetBaseType = false;
if isInport
isValueModeToGetBaseType = strcmp( ioAccessMode, 'BY_VALUE' );
end 

isReferenceMode = strcmp( ioAccessMode, 'BY_REFERENCE' );
if isReferenceMode || isValueModeToGetBaseType
lBaseType = prototype.Return.Type;
else 
lBaseType = prototype.Arguments( 1 ).Type;
end 
[ lBaseType, ~ ] = getBaseType( lBaseType );
assert( isprop( lBaseType, 'Identifier' ) );
baseTypeName = lBaseType.Identifier;

function [ baseType, isReadOnlyAtAnyPoint ] = getBaseType( baseType )
isReadOnlyAtAnyPoint = false;
while isa( baseType, 'coder.descriptor.types.Pointer' ) ||  ...
isa( baseType, 'coder.descriptor.types.Matrix' )
baseType = baseType.BaseType;
if ( ~isReadOnlyAtAnyPoint )
isReadOnlyAtAnyPoint = baseType.ReadOnly;
end 
end 
end 
end 

end 

function headers = getHeadersForSymbol( componentInterface, symbolName )
headers = {  };
symbolNode = componentInterface.getGlobalSymbolNodeByName( symbolName );
if ~isempty( symbolNode ) && ~isempty( symbolNode.HeaderFiles )
headers = symbolNode.HeaderFiles.toArray;
end 
end 

end 

function writeTrailer( writer, rteFileName )

bannerFileName = strrep( rteFileName, '.', '_' );
writer.wLine( '#endif /* RTW_HEADER_%s */', bannerFileName );

end 

function updateBuildInfo( buildInfo, intFolder )



buildInfo.addIncludePaths( intFolder );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpryPdmq.p.
% Please follow local copyright laws when handling this file.

