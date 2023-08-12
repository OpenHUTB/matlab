


function validateCell = validateProjectFolder( obj, folderPath )


if nargin < 2
folderPath = obj.getProjectFolder;
end 

validateCell = {  };

projectFolderMsg = message( 'HDLShared:hdldialog:HDLWAEDKToolFolderStr' );


downstream.tool.validateFolder( folderPath, projectFolderMsg.getString );


absPath = downstream.tool.getAbsoluteFolderPath( folderPath );


if contains( absPath, ' ' )
msgObject = message( 'hdlcommon:workflow:SpaceInPathWarn', projectFolderMsg.getString, absPath );
validateCell{ end  + 1 } = hdlvalidatestruct( 'Warning', msgObject );
end 




invalidCharList = { '!', '#', '$', '%', '^', '&', '*', '(', ')', '`', ';', '<', '>', '?', ',', '[', ']', '{', '}', '''', '"', '|', sprintf( '\t' ), sprintf( '\r' ), sprintf( '\n' ) };%#ok<SPRINTFN> 
if obj.isVivado && contains( absPath, invalidCharList )
invalidCharStr = [ strjoin( invalidCharList( 1:end  - 3 ) ), newline, 'tab (\t)', newline, 'return (\r)', newline, 'new line (\n)' ];
msgObject = message( 'hdlcommon:workflow:InvalidCharInPathWarn', invalidCharStr, projectFolderMsg.getString, absPath );
validateCell{ end  + 1 } = hdlvalidatestruct( 'Warning', msgObject );
end 




if obj.isIPCoreGen && ~isempty( obj.hTurnkey ) && obj.hTurnkey.isVersalPlatform



pathWarnLen = 65;
else 
pathWarnLen = 80;
end 
if ispc && length( absPath ) > pathWarnLen
msgObject = message( 'hdlcommon:workflow:LongPathWarn', projectFolderMsg.getString, absPath, pathWarnLen );
validateCell{ end  + 1 } = hdlvalidatestruct( 'Warning', msgObject );
end 



modelName = obj.getModelName;
hfpLibrary = hdlget_param( modelName, 'FloatingPointTargetConfiguration' );
family = hdlget_param( modelName, 'SynthesisToolChipFamily' );
synthTool = obj.getToolName;
workFlow = obj.get( 'Workflow' );
if ~isempty( hfpLibrary )
if ( strcmpi( synthTool, 'Intel Quartus Pro' ) && strcmpi( workFlow, 'IP Core Generation' ) && strcmpi( hfpLibrary.Library, 'ALTERAFPFUNCTIONS' ) )
msgObject2 = message( 'hdlcommon:workflow:HFPNotSupportedQpro' );
validateCell{ end  + 1 } = hdlvalidatestruct( 'Error', msgObject2 );
return ;
end 
if ( strcmpi( synthTool, 'Intel Quartus Pro' ) && strcmpi( workFlow, 'Generic ASIC/FPGA' ) && strcmpi( hfpLibrary.Library, 'ALTERAFPFUNCTIONS' ) && strcmpi( family, 'Agilex' ) )
pathToQuartusPro = hdlgetpathtoquartuspro;
[ qproPath, ~, ~ ] = fileparts( pathToQuartusPro );
qshPath = fullfile( qproPath, 'quartus_sh' );
qproVersionCmd = sprintf( '%s --tcl_eval  puts $quartus(version)', qshPath );
[ ~, Ver ] = system( qproVersionCmd );
qproVersion = str2double( Ver( 9:12 ) );
if qproVersion < 20.1
msgObject3 = message( 'hdlcommon:workflow:HFPNotSupportedAgilex' );
validateCell{ end  + 1 } = hdlvalidatestruct( 'Error', msgObject3 );
return ;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpwTkrLn.p.
% Please follow local copyright laws when handling this file.

