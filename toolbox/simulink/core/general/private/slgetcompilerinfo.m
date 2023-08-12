function CompilerInfo = slgetcompilerinfo





if isunix
DAStudio.error( 'Simulink:blocks:slgetcompilerinfIsUNIXorMAC' );
return ;
else 
cc = mex.getCompilerConfigurations( 'C', 'Selected' );
if ( isempty( cc ) )
CompilerInfo.compilerName = 'lcc';
CompilerInfo.mexOptsFile = '';
return ;
else 
CompilerInfo.compilerName = lower( strtrim( cc.ShortName ) );
CompilerInfo.mexOptsFile = cc.MexOpt;
end 


end 


function str = localFile2str( fileName )

fid = fopen( fileName, 'r' );
F = fread( fid );
str = char( F' );
fclose( fid );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMNiv2D.p.
% Please follow local copyright laws when handling this file.

