function normal_path = enc2normalpath( enc_path )





if ~ischar( enc_path )
DAStudio.error( 'Simulink:tools:enc2normalpathFirstArgError' );
end 

normal_path = slInternal( 'enc2normalpath', enc_path );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBxeEi2.p.
% Please follow local copyright laws when handling this file.

