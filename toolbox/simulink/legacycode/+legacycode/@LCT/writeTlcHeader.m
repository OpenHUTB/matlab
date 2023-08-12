function writeTlcHeader( h, fid, infoStruct )%#ok<INUSL>





thisDate = datestr( now, 0 );
slVer = ver( 'simulink' );

fprintf( fid, '%%%% File : %s.tlc\n', infoStruct.Specs.SFunctionName );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%%% Description: \n' );
fprintf( fid, '%%%%   Simulink Coder TLC Code Generation file for %s\n',  ...
infoStruct.Specs.SFunctionName );
fprintf( fid, '%%%%\n' );

fprintf( fid, '%%%% Simulink version      : %s %s %s\n', slVer.Version, slVer.Release, slVer.Date );
fprintf( fid, '%%%% TLC file generated on : %s\n', thisDate );
fprintf( fid, '\n' );



fprintf( fid, '/%%\n' );
fprintf( fid, '     %%%%%%-MATLAB_Construction_Commands_Start\n' );
fprintf( fid, '%s', legacycode.LCT.generateSpecConstructionCmd( infoStruct.Specs, 'tlc' ) );
fprintf( fid, '     %%%%%%-MATLAB_Construction_Commands_End\n' );
fprintf( fid, ' %%/\n' );
fprintf( fid, '\n' );

fprintf( fid, '%%implements %s "C"\n', infoStruct.Specs.SFunctionName );
fprintf( fid, '\n' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvsRf9z.p.
% Please follow local copyright laws when handling this file.

