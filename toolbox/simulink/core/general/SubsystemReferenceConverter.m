








classdef SubsystemReferenceConverter < handle




methods ( Static, Access = 'public' )


function [ status, message ] =  ...
createSubsystemReference( BlockHandle, NewFileName, ConvertBlock )

obj = SubsystemReferenceConverter( BlockHandle, NewFileName, ConvertBlock );
[ status, message ] = obj.convertSubsystem(  );
end 

end 

methods ( Access = 'public' )




function obj = SubsystemReferenceConverter( inBlockHandle,  ...
inNewFilePath, inConvertBlock )
obj.m_block_handle = get_param( inBlockHandle, 'handle' );

[ path, file_name, ext ] = fileparts( inNewFilePath );
if isempty( ext )
ext = [ '.', get_param( 0, 'ModelFileFormat' ) ];
end 
if isempty( path )
path = pwd;
end 

obj.m_new_file_path = [ path, filesep, file_name, ext ];
obj.m_new_file_name = file_name;

obj.m_convert_block = inConvertBlock;
obj.m_reportedittimeerrorfromsetparam_feature_value =  ...
slfeature( 'ReportMaskEditTimeErrorsFromSetParam', 0 );
end 

function delete( this )
slfeature( 'ReportMaskEditTimeErrorsFromSetParam',  ...
this.m_reportedittimeerrorfromsetparam_feature_value );
end 



function [ status, errorMessage ] = convertSubsystem( this )
[ status, errorMessage ] =  ...
SSRefUtil.passesSSRefChecksForConversion( this.m_block_handle );
if ~status
return ;
end 

SSRefUtil.deleteFunctionInterfaces( getfullname( this.m_block_handle ) );



try 
if Simulink.internal.isArchitectureModel( bdroot( this.m_block_handle ), 'Architecture' )

converter = systemcomposer.internal.arch.internal.SubsystemToSubsystemReferenceConverter( this.m_block_handle, this.m_new_file_name );
converter.convertToSubsystemReference(  );
else 

aInterceptorHandler = Simulink.output.StorageInterceptorCb(  );
aScopedInterceptor = Simulink.output.registerProcessor( aInterceptorHandler );%#ok<NASGU>

[ status, errorMessage ] = this.copySubsystemContentsAndMask(  );
if ( ~status )
return ;
end 

if ( this.m_convert_block )
status = this.convertSubsystemToSubsystemReference(  );
end 


aWarningDiagnostic = aInterceptorHandler.lastInterceptedMsg(  );
if ~isempty( aWarningDiagnostic )
warndlg( slprivate( 'removeHyperLinksFromMessage', aWarningDiagnostic.Message ),  ...
DAStudio.message( 'Simulink:SubsystemReference:ConvertToSRDlgTitleText' ), 'modal' );
end 
end 
catch exp
if ~isempty( this.m_new_blockdiagram )
close_system( this.m_new_blockdiagram, 0 );
end 
status = false;
errorMessage = getExceptionMsgReport( exp );
end 

end 



function bdHandle = getSubsystemBDHandle( this )
bdHandle = this.m_new_blockdiagram;
end 


end 


methods ( Access = 'private' )


function [ status, message ] = createNewSystem( this )

[ is_loaded, loaded_file_path ] = SRDialogHelper.findLoadedFile( this.m_new_file_name );




if ( is_loaded && ~strcmp( loaded_file_path, this.m_new_file_path ) )
message = DAStudio.message(  ...
'Simulink:SubsystemReference:BDAlreadyLoaded', this.m_new_file_name, loaded_file_path );
status = false;
return ;
end 

if ( is_loaded )
close_system( this.m_new_file_name );
end 


[ ~, temp_name, ~ ] = fileparts( tempname );
this.m_new_blockdiagram = new_system( temp_name, 'subsystem' );
message = '';
status = true;
end 



function [ status, message ] = copySubsystemContentsAndMask( this )
[ status, message ] = this.createNewSystem(  );
if ( ~status )
return ;
end 


Simulink.SubSystem.copyContentsToBlockDiagram(  ...
this.m_block_handle, this.m_new_blockdiagram );
this.copyMaskIfPresent(  );



this.correctLinkStatus(  );

set_param( this.m_new_blockdiagram, 'SetExecutionDomain', get_param( this.m_block_handle, 'SetExecutionDomain' ) );
set_param( this.m_new_blockdiagram, 'ExecutionDomainType', get_param( this.m_block_handle, 'ExecutionDomainType' ) );

save_system( this.m_new_blockdiagram, this.m_new_file_path );
status = true;
end 



function status = convertSubsystemToSubsystemReference( this )


Simulink.Internal.closeOpenGraphAndSubGraphs( this.m_block_handle );



set_param( this.m_block_handle, 'Mask', 'off' );


set_param( this.m_block_handle, 'ReferencedSubsystem', this.m_new_file_name );


status = true;
end 



function copyMaskIfPresent( this )

subsys_mask = Simulink.Mask.get( this.m_block_handle );
if ( ~isempty( subsys_mask ) )



this.removeUnsupportedPromotedParameters( subsys_mask );

new_mask = Simulink.Mask.create( this.m_new_blockdiagram );
new_mask.copy( subsys_mask );
if ~isempty( new_mask.ImageFile ) && strncmp( new_mask.ImageFile, 'slx:/', 4 )


Simulink.Mask.convertToExternalImage( this.m_new_blockdiagram );
end 


ev = DAStudio.EventDispatcher;
ev.broadcastEvent( 'ObjectStateChangedEvent', get_param( this.m_block_handle, 'object' ), 'MaskChanged' );
end 
end 



function removeUnsupportedPromotedParameters( this, subsys_mask )

i = 1;
showWarning = false;
removedParameters = '';
while i <= length( subsys_mask.Parameters )

if ( strcmpi( subsys_mask.Parameters( i ).Type, 'promote' ) ) &&  ...
this.isParameterPromotedToItself( subsys_mask.Parameters( i ) )

parameterName = subsys_mask.Parameters( i ).Name;
subsys_mask.removeParameter( parameterName );

showWarning = true;

if isempty( removedParameters )
removedParameters = parameterName;
else 
removedParameters = strcat( removedParameters, ", ", parameterName );
end 
else 
i = i + 1;
end 
end 

if ( showWarning )
MSLDiagnostic( 'Simulink:SubsystemReference:SkippingParametersWhileSSRefConversion', removedParameters ).reportAsWarning;
end 

end 



function flag = isParameterPromotedToItself( ~, aMaskParameter )

typeOptions = aMaskParameter.TypeOptions;
flag = false;

for i = 1:length( typeOptions )
option = typeOptions{ i };
if ( ~contains( option, '/' ) )
flag = true;
return ;
end 
end 
end 



function correctLinkStatus( this )
if ~bdIsLibrary( bdroot( this.m_block_handle ) )
return ;
end 

aBlockFullPath = getfullname( this.m_block_handle );

aLinkBlocks = find_system( this.m_new_blockdiagram, 'SearchDepth', 1, 'LinkStatus', 'resolved' );
for i = 1:length( aLinkBlocks )
if strcmp( get_param( aLinkBlocks( i ), 'ReferenceBlock' ), [ aBlockFullPath, '/', get_param( aLinkBlocks( i ), 'Name' ) ] )
set_param( aLinkBlocks( i ), 'LinkStatus', 'none' );
end 
end 
end 

end 

properties ( Access = 'private' )
m_block_handle;
m_new_file_path;
m_new_file_name;
m_convert_block;
m_new_blockdiagram;
m_reportedittimeerrorfromsetparam_feature_value;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpU8YTn5.p.
% Please follow local copyright laws when handling this file.

