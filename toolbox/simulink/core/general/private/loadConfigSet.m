function loadConfigSet( model, filename )




[ pathstr, name, ext ] = fileparts( filename );
filename = fullfile( pathstr, [ name, ext ] );
active_CS_model = getActiveConfigSet( model );


if ( strcmp( ext, '.m' ) || strcmp( ext, '.mlx' ) )
cls = internal.matlab.codetools.reports.matlabType.findType( filename );

if ~isa( cls, 'internal.matlab.codetools.reports.matlabType.Function' )
DAStudio.error( 'Simulink:ConfigSet:notMATLABFunction', filename );
end 

curDir = pwd;
cd( pathstr );

try 
newCS = eval( name );
catch ME
DAStudio.error( 'Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename );
end 


if nargout( name ) > 1
DAStudio.error( 'Simulink:ConfigSet:badMATLABFunctionMultiConfigSet', filename );
end 


if ~isa( newCS, 'Simulink.ConfigSet' )
DAStudio.error( 'Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename );
end 
cd( curDir );
else 

objInMAT = load( filename );


csIdx = 0;
f = fields( objInMAT );
for i = 1:length( f )
if isa( objInMAT.( f{ i } ), 'Simulink.ConfigSet' )
if ~csIdx
csIdx = i;
else 
DAStudio.error( 'Simulink:ConfigSet:multipleCSinMATFile' );
end 
end 
end 


if csIdx == 0
DAStudio.error( 'Simulink:ConfigSet:noCSinMATFile' );
end 


if length( f ) > 1
MSLDiagnostic( 'Simulink:ConfigSet:otherObjsinMATFile' ).reportAsWarning;
end 

newCS = objInMAT.( f{ csIdx } );
end 

allCS = getConfigSets( model );


if any( strcmp( allCS, newCS.Name ) );
toReplace = questdlg( DAStudio.message( 'RTW:configSet:saveAsGUIImportOverwrite', newCS.Name ),  ...
DAStudio.message( 'RTW:configSet:objectiveWarningTitle' ),  ...
DAStudio.message( 'RTW:configSet:configSetObjectivesFinishButtonName' ),  ...
DAStudio.message( 'RTW:configSet:configSetObjectivesCancelButtonName' ),  ...
DAStudio.message( 'RTW:configSet:configSetObjectivesFinishButtonName' ) );
if strcmp( toReplace, DAStudio.message( 'RTW:configSet:configSetObjectivesCancelButtonName' ) )

return ;
end 
else 

attachConfigSet( model, newCS );
return ;
end 


if ~strcmp( newCS.Name, active_CS_model.Name )

detachConfigSet( model, newCS.Name );
attachConfigSet( model, newCS );
else 

cs_copy = newCS.copy;
cs_copy_name = cs_copy.Name;
attachConfigSet( model, cs_copy, 1 );
setActiveConfigSet( model, cs_copy.Name );
detachConfigSet( model, active_CS_model.Name );
cs_copy.Name = cs_copy_name;

if isa( active_CS_model, 'Simulink.ConfigSetRef' )
MSLDiagnostic( 'Simulink:ConfigSet:warningToReplaceConfigSetRef', get_param( model, 'Name' ) ).reportAsWarning;
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdULAx_.p.
% Please follow local copyright laws when handling this file.

