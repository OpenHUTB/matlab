function setProcessingUnitName( hObj, cpuName )


if isa( hObj, 'Simulink.ConfigSet' ) ||  ...
isa( hObj, 'Simulink.ConfigSetRef' )
hCS = hObj;
elseif isa( hObj, 'CoderTarget.SettingsController' )
hCS = hObj.getConfigSet;
else 

hCS = getActiveConfigSet( hObj );
end 

if codertarget.data.isValidParameter( hCS, 'ESB.ProcessingUnit' ) &&  ...
~isequal( codertarget.targethardware.getProcessingUnitName( hCS ), cpuName )

hCS.openDialog;
clDlgH = onCleanup( @(  )hCS.closeDialog );
i_set_param( hCS, 'Tag_ConfigSet_CoderTarget_SOCB_ProcessingUnit', cpuName );
end 
end 

function i_set_param( cs, widgetTag, widgetValue )

dlg = cs.getDialogHandle;
dlgsrc = dlg.getDialogSource;
if isa( dlgsrc, 'configset.dialog.HTMLView' )
jsTag = jsonencode( widgetTag );
jsValue = jsonencode( widgetValue );
js = sprintf( 'qe.setWidgetValue(%s, %s)', jsTag, jsValue );
try 
dlgsrc.evalJS( js );
catch exc
if ~isequal( exc.identifier, 'MATLAB:json:ExpectedValueAtEnd' )
throw( exc )
end 
end 



maxCnt = 30;
cnt = 0;
isVisible = false;
while ( cnt <= maxCnt ) && isequal( isVisible, false )
pause( 1 );
isVisible = i_isWidgetVisible( cs, 'Tag_ConfigSet_CoderTarget_SOCB_HW_Show_In_SDI' );

cnt = cnt + 1;
end 

dlg.apply;
else 
end 
end 

function isVisible = i_isWidgetVisible( cs, widgetTag )
isVisible = false;

dlg = cs.getDialogHandle;
dlgsrc = dlg.getDialogSource;
if isa( dlgsrc, 'configset.dialog.HTMLView' )
jsTag = jsonencode( widgetTag );

js = sprintf( 'qe.getWidgetStruct(%s)', jsTag );
try 
widgetStruct = dlgsrc.evalJS( js );
catch exc
if ~isequal( exc.identifier, 'MATLAB:json:ExpectedValueAtEnd' )
throw( exc )
end 
end 
if isempty( widgetStruct )
isVisible = false;
else 
isVisible = widgetStruct.Visible;
end 
else 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0VzqLa.p.
% Please follow local copyright laws when handling this file.

