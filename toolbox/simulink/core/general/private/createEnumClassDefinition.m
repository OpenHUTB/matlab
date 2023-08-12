function createEnumClassDefinition( variableName, modelName, classSuggestion, blockFullName )









if ~strcmp( classSuggestion, 'Enum' )

return ;
end 


[ fileName, filePath ] = uiputfile( '.m', DAStudio.message( 'Simulink:dialog:VariableNavigation_CreateEnumClass' ), variableName );

if any( fileName == 0 ) || any( filePath == 0 )

return ;
end 


fullFileName = fullfile( filePath, fileName );
fileName = strrep( fileName, '.m', '' );
fileID = fopen( fullFileName, 'w' );
settingsGroup = settings;
tabSize = settingsGroup.matlab.editor.tab.TabSize.ActiveValue;

fprintf( fileID, [ 'classdef ', fileName, ' < Simulink.IntEnumType\n',  ...
[ blanks( tabSize ), 'enumeration\n' ],  ...
[ blanks( tabSize * 2 ), 'enum1(0)\n' ] ...
, [ blanks( tabSize ), 'end\n' ],  ...
[ blanks( tabSize ), 'methods (Static)\n' ],  ...
[ blanks( tabSize * 2 ), 'function retVal = getDefaultValue()\n' ],  ...
[ blanks( tabSize * 3 ), 'retVal = ', fileName, '.enum1;\n' ],  ...
[ blanks( tabSize * 2 ), 'end\n' ],  ...
[ blanks( tabSize ), 'end\n' ],  ...
'end\n'
 ] );
fclose( fileID );


slprivate( 'edit', fullFileName );


betcObj = blkEditTimeCheck( modelName, blockFullName );
blkEditTimeCheck.refreshEditTimeNotifications( betcObj );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpybNZ5M.p.
% Please follow local copyright laws when handling this file.

