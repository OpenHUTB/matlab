function [ status, message ] = ModelDDLinks_cb( hController, hDlg, tag, action )






switch action
case 'OK'
hController.rootAdapter.applyChanges(  );
hController.rootAdapter.close(  );



case 'Cancel'
hController.rootAdapter.close(  );


case 'Help'



case 'Apply'

hController.rootAdapter.applyChanges(  );
hDlg.setEnabled( 'ModelDDLinks_Apply', false );








end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHFbeHe.p.
% Please follow local copyright laws when handling this file.

