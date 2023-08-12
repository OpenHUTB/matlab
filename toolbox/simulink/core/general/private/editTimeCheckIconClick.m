function editTimeCheckIconClick( src, propName, textToParse, pos, dialogHandle, widgetTag )



try 
dlgSrc = src;
vars = {  };
if isa( dlgSrc.getDialogSource, 'Simulink.SLDialogSource' )
var_name = dlgSrc.findMissingVariables( textToParse, propName );
else 
var_name = textToParse;
end 
if ~iscell( var_name )
vars = { var_name };
else 
vars = var_name;
end 
varList = unique( vars, 'stable' );
[ parent, blockFullName, dlgSrc, ~ ] = slprivate( 'getBlockInformationFromSource', dlgSrc );
classSuggestion = dlgSrc.getClassSuggestion( propName );
mdlName = l_setDialogDetails( parent, blockFullName );
if isempty( vars )




blkEditTimeCheck.openDialogsRefresh( get_param( blockFullName, 'Handle' ) );
else 
dlgStruct = blkEditTimeCheck( mdlName, blockFullName, propName, varList, pos, classSuggestion );
diagnostics = dlgStruct.getDiagnostics(  );

sevError = Simulink.output.utils.Severity.Error;
diagArr = [  ];
for i = 1:length( diagnostics )
dataObj = Simulink.output.DiagnosticWidgetData( diagnostics( i ), 'Severity', sevError );
diagArr = [ diagArr, dataObj ];
end 
spec = Simulink.output.targetspecifiers.ddg( dialogHandle, widgetTag );
x = Simulink.output.DiagnosticWidget( diagArr, spec );
if isa( src, 'Simulink.Line' )
handle = src.getSourcePort.Handle;
fh = @(  )blkEditTimeCheck.openDialogsRefresh( handle );
elseif isa( src, 'Simulink.Port' )
handle = src.Handle;
fh = @(  )blkEditTimeCheck.openDialogsRefresh( handle );
else 
fh = @(  )blkEditTimeCheck.openDialogsRefresh( get_param( blockFullName, 'Handle' ) );
end 
x.setCloseCallback( fh );
x.show(  );
end 
catch E
end 
end 

function [ mdlName ] = l_setDialogDetails( parent, blockFullName )
if ~isempty( parent ) && ~isempty( blockFullName )
root = parent;
while ~isa( root, 'Simulink.BlockDiagram' )
root = root.getParent;
end 
mdlName = root.getFullName;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYaa1KU.p.
% Please follow local copyright laws when handling this file.

