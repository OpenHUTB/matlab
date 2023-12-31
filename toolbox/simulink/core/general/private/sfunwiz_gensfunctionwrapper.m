function sfunwiz_gensfunctionwrapper( sfunNameWrapper, INWrapper, timeString, FlagGenHeaderFile, sfunBusHeaderFile, bus_Header_List, headerArray, NumberOfInputPorts, NumberOfOutputPorts, FlagDynSizedInput, FlagDynSizedOutput,  ...
InDimsAbs, OutDimsAbs, externDeclarations, fcnProtoTypeStart, fcnProtoTypeOutput, fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeTerminate, mdlStartArray, mdlOutputArray, discStatesArray, contStatesArray, mdlTerminateArray, UseSimStruct )












fileHandler = fopen( sfunNameWrapper, 'W', 'n', slCharacterEncoding );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForWrite', sfunNameWrapper );
end 

lines = regexp( INWrapper, '\n', 'split' );
lines( 1:2 ) = [  ];
clear INWrapper

for lineCell = lines
line = lineCell{ : };

printInfoTag = regexp( line, '^\s*--(\<.+\>)--\s*$', 'tokens', 'once' );

if ( isempty( printInfoTag ) )
fprintf( fileHandler, '%s\n', line );
continue ;
end 

switch printInfoTag{ : }
case 'WrapperIntroduction'
strIntro = genWrapperIntro( timeString );
fprintf( fileHandler, '%s\n', strIntro );

case 'IncludeSimStructOrRTWTypes'
fprintf( fileHandler, '%s', getIncludeTypes( UseSimStruct ) );

case 'IncludeBusHeader'
if ( FlagGenHeaderFile )
fprintf( fileHandler, '\n#include "%s"\n', sfunBusHeaderFile );
else 
fprintf( fileHandler, '\n%s\n', bus_Header_List );
end 

case 'IncludeHeaders'
fprintf( fileHandler, '%s', headerArray );

case 'DefinesWidths'
portIdNum = find( cellfun( @( x )prod( x ) > 0, InDimsAbs ) == 1 ) - 1;
tempCellToPrint = [  ...
num2cell( portIdNum );num2cell( cellfun( @( x )prod( x ), InDimsAbs( cellfun( @( x )prod( x ) > 0, InDimsAbs ) ) ) ) ...
 ];
if ( NumberOfInputPorts > 0 && ~isempty( tempCellToPrint ) )
tempStr = sprintf( '#define u_%d_width %d\n', tempCellToPrint{ : } );

tempStr = strrep( tempStr, 'u_0_width', 'u_width' );
fprintf( fileHandler, '%s', tempStr );
end 
portIdNum = find( cellfun( @( x )prod( x ) > 0, OutDimsAbs ) == 1 ) - 1;
tempCellToPrint = [  ...
num2cell( portIdNum );num2cell( cellfun( @( x )prod( x ), OutDimsAbs( cellfun( @( x )prod( x ) > 0, OutDimsAbs ) ) ) ) ...
 ];
if ( NumberOfOutputPorts > 0 && ~isempty( tempCellToPrint ) )
tempStr = sprintf( '#define y_%d_width %d\n', tempCellToPrint{ : } );

tempStr = strrep( tempStr, 'y_0_width', 'y_width' );
fprintf( fileHandler, '%s', tempStr );
end 

case 'WrapperExternalDeclarations'
fprintf( fileHandler, '%s', externDeclarations );

case 'mdlStartFcnPrototype'
fprintf( fileHandler, '%s\n', fcnProtoTypeStart );

case 'mdlStartFcnCode'
fprintf( fileHandler, '%s\n', mdlStartArray );

case 'mdlOutputsFcnPrototype'


fcnProtoTypeOutput = strrep( fcnProtoTypeOutput, 'u_0_width', 'u_width' );
fcnProtoTypeOutput = strrep( fcnProtoTypeOutput, 'y_0_width', 'y_width' );
fprintf( fileHandler, '%s\n', fcnProtoTypeOutput );

case 'mdlOutputsFcnCode'
fprintf( fileHandler, '%s\n', mdlOutputArray );

case 'mdlUpdateFcnPrototype'


fcnProtoTypeUpdate = strrep( fcnProtoTypeUpdate, 'u_0_width', 'u_width' );
fcnProtoTypeUpdate = strrep( fcnProtoTypeUpdate, 'y_0_width', 'y_width' );
fprintf( fileHandler, '%s\n', fcnProtoTypeUpdate );

case 'mdlUpdateFcnCode'
fprintf( fileHandler, '%s\n', discStatesArray );

case 'mdlDerivativesFcnPrototype'


fcnProtoTypeDerivatives = strrep( fcnProtoTypeDerivatives, 'u_0_width', 'u_width' );
fcnProtoTypeDerivatives = strrep( fcnProtoTypeDerivatives, 'y_0_width', 'y_width' );
fprintf( fileHandler, '%s\n', fcnProtoTypeDerivatives );

case 'mdlDerivativesFcnCode'
fprintf( fileHandler, '%s\n', contStatesArray );

case 'mdlTerminateFcnPrototype'
fprintf( fileHandler, '%s\n', fcnProtoTypeTerminate );

case 'mdlTerminateFcnCode'
fprintf( fileHandler, '%s\n', mdlTerminateArray );
end 
end 

fclose( fileHandler );

end 

function includeTypes = getIncludeTypes( UseSimStruct )
if ( UseSimStruct )
includeTypes = sprintf( '#include "simstruc.h"\n' );
else 






includeTypes = sprintf( [ '#if defined(MATLAB_MEX_FILE)\n' ...
, '#include "tmwtypes.h"\n' ...
, '#include "simstruc_types.h"\n' ...
, '#else\n' ...
, '#define SIMPLIFIED_RTWTYPES_COMPATIBILITY\n' ...
, '#include "rtwtypes.h"\n' ...
, '#undef SIMPLIFIED_RTWTYPES_COMPATIBILITY\n' ...
, '#endif\n' ...
 ] );
end 
end 

function wrapperIntro = genWrapperIntro( timeString )
wrapperIntro = [ '/*', ( newline ) ...
, '  *', ( newline ) ...
, '  *   \\--- THIS FILE GENERATED BY S-FUNCTION BUILDER: 3.0 \\---', ( newline ) ...
, '  *', ( newline ) ...
, '  *   This file is a wrapper S-function produced by the S-Function', ( newline ) ...
, '  *   Builder which only recognizes certain fields.  Changes made', ( newline ) ...
, '  *   outside these fields will be lost the next time the block is', ( newline ) ...
, '  *   used to load, edit, and resave this file. This file will be overwritten', ( newline ) ...
, '  *   by the S-function Builder block. If you want to edit this file by hand, ', ( newline ) ...
, '  *   you must change it only in the area defined as:  ', ( newline ) ...
, '  *', ( newline ) ...
, '  *        %%%-SFUNWIZ_wrapper_XXXXX_Changes_BEGIN ', ( newline ) ...
, '  *            Your Changes go here', ( newline ) ...
, '  *        %%%-SFUNWIZ_wrapper_XXXXXX_Changes_END', ( newline ) ...
, '  *', ( newline ) ...
, '  *   For better compatibility with the Simulink Coder, the', ( newline ) ...
, '  *   "wrapper" S-function technique is used.  This is discussed', ( newline ) ...
, '  *   in the Simulink Coder User''s Manual in the Chapter titled,', ( newline ) ...
, '  *   "Wrapper S-functions".', ( newline ) ...
, '  *', ( newline ) ...
, '  *   Created: ', timeString, ( newline ) ...
, '  */', ( newline ) ...
 ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFFYUDC.p.
% Please follow local copyright laws when handling this file.

