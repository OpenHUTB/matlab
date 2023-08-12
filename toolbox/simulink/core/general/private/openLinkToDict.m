function openLinkToDict( modelName )




open_system( modelName );

tag = [ '_DDG_MP_', modelName, '_TAG_' ];

tr = DAStudio.ToolRoot;
openDlgs = tr.getOpenDialogs;
dlgs = openDlgs.find( 'DialogTag', tag );
dlgProps = '';
for i = 1:length( dlgs )
if dlgs( i ).isStandAlone
dlgProps = dlgs( i );
break ;
end 
end 

if isempty( dlgProps )
obj = get_param( modelName, 'Object' );
dlgProps = DAStudio.Dialog( obj, tag, 'DLG_STANDALONE' );
end 

imd = DAStudio.imDialog.getIMWidgets( dlgProps );
tabbar = imd.find( 'tag', 'Tabcont' );
tabs = tabbar.find( '-isa', 'DAStudio.imTab' );
if slfeature( 'ShowExternalDataNode' ) > 0
tabName = DAStudio.message( 'Simulink:dialog:ModelDataTabName_External' );
else 
tabName = DAStudio.message( 'Simulink:dialog:ModelDataTabName' );
end 

for i = 1:length( tabs )
if isequal( tabs( i ).getName, tabName )
dlgProps.setActiveTab( 'Tabcont', i - 1 );
break ;
end 
end 

dlgProps.show;

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIGccS8.p.
% Please follow local copyright laws when handling this file.

