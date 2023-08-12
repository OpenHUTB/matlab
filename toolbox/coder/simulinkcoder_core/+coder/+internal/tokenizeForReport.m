function tokenizeForReport( srcFiles, htmlFiles, encoding, genTraceHyperlink, varargin )




genReport = true;
if nargin == 5
genReport = varargin{ 1 };
end 

arch = lower( computer );
if strcmp( arch, 'pcwin' )
arch = 'win32';
elseif strcmp( arch, 'pcwin64' )
arch = 'win64';
end 
conv = fullfile( matlabroot, 'toolbox', 'coder', 'simulinkcoder_core', '+Simulink', '+report', 'bin', arch, 'mwtokenizer' );




tmpFile = tempname;
fid = fopen( tmpFile, 'w' );
for i = 1:length( srcFiles )
fprintf( fid, '%s\n%s\n', srcFiles{ i }, htmlFiles{ i } );
end 
fclose( fid );

try 
system( [ '"', conv, '" "', tmpFile, '" "', encoding, '" ', int2str( genTraceHyperlink ), ' ', int2str( genReport ) ] );
catch me
disp( me.message(  ) );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpFFpFEm.p.
% Please follow local copyright laws when handling this file.

