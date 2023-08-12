function [ status, desc ] = slxcfinfo( pkgFile )




try 

[ masterInfo, masterInfoMdl ] = builtin( '_getSLCacheMasterInformation', pkgFile );%#ok<ASGLU>


status = getString( message( 'Simulink:cache:fileType' ) );


desc = getString( message( 'Simulink:cache:finfoValidSLXCFile' ) );
catch ME %#ok<NASGU>

desc = '';
status = '';
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpKavTSN.p.
% Please follow local copyright laws when handling this file.

