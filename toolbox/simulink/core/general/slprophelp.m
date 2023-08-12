function slprophelp( dialog_type )









doc_path = docroot;
if isempty( doc_path )
helpview( [ matlabroot, '/toolbox/local/helperr.html' ] );
return ;
end 

doc_path = [ doc_path, '/mapfiles/simulink.map' ];
switch dialog_type
case 'model'
helpview( doc_path, 'modelpropertiesdialog' )

case 'block'
helpview( doc_path, 'blockpropertiesdialog' )
case 'sigandscopemgr'
helpview( [ docroot, '/mapfiles/simulink.map' ], 'signal_and_scope_mgr' );
case 'signal'
helpview( doc_path, 'signalpropertiesdialog' )

case 'state'
rtw_ug_mapfile = fullfile( docroot, 'mapfiles', 'rtw_ug.map' );
if exist( rtw_ug_mapfile, 'file' )
helpview( rtw_ug_mapfile, 'rtw_block_states' )
else 
helpview( doc_path, 'statepropertiesdialog' )
end 

case 'maskeditor'
helpview( doc_path, 'maskeditordialog' )

case 'buseditor'
helpview( doc_path, 'bus_editor' )

case 'editedlinkstool'
helpview( [ docroot, '/toolbox/simulink/ug/simulink_ug.map' ], 'editedlinkstool' );

case 'restore-disabled-links-id'
helpview( [ docroot, '/toolbox/simulink/ug/simulink_ug.map' ], 'restore-disabled-links-id' )

case 'restore-parameterized-links-id'
helpview( [ docroot, '/toolbox/simulink/ug/simulink_ug.map' ], 'restore-parameterized-links-id' );

otherwise 
DAStudio.error( 'Simulink:dialog:SlprophelpInvalidProperty', dialog_type );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbnHzpC.p.
% Please follow local copyright laws when handling this file.

