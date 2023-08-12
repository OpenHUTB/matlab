function simRFV2TestbenchLshowInstr( BlockName )


if ( nargin == 0 )

BlockName = 'Testbench';
end 
open_system( [ bdroot, '/', BlockName ], 'mask' )


tr = DAStudio.ToolRoot;
dlgs = tr.getOpenDialogs;
for dlgIndx = 1:size( dlgs )


if ( isa( dlgs( dlgIndx ).getDialogSource, 'Simulink.SLDialogSource' ) &&  ...
strcmp( dlgs( dlgIndx ).getDialogSource.getBlock.name, BlockName ) )
imd = DAStudio.imDialog.getIMWidgets( dlgs( dlgIndx ) );
if isa( imd, 'DAStudio.imDialog' )
DescGroupVarWidget = imd.find( 'tag', 'DescGroupVar' );



if ( isa( DescGroupVarWidget, 'DAStudio.imGroup' ) &&  ...
~isempty( strfind( DescGroupVarWidget.name, '(mask)' ) ) )

dlgs( dlgIndx ).setActiveTab( 'TabContainer', 1 )
return ;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpotvW24.p.
% Please follow local copyright laws when handling this file.

