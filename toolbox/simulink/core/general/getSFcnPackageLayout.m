function ExtTable = getSFcnPackageLayout





ExtTable = struct;
ExtTable.src = { 'c', 'cpp', 'h', 'hpp', 'f', 'f90', 'f95', 'f03', 'for' };
ExtTable.libs = { 'lib', 'obj', 'o', 'a' };
ExtTable.artifacts = { 'mat', 'xml', 'txt', 'json', 'pdf', 'html', 'png' };
ExtTable.tlc = { 'tlc' };
ExtTable.mFiles = { 'm' };


s = mexext( 'all' );
for i = 1:numel( s )
archStr = s( i ).arch;
if strcmp( archStr, 'win32' )

continue 
end 
slibs = {  };
if contains( archStr, 'linux' ) || contains( archStr, 'glnx' )
slibs = { 'so' };
elseif contains( archStr, 'mac' )
slibs = { 'dylib' };
elseif contains( archStr, 'win' )
slibs = { 'dll' };
end 


archStr( ~isstrprop( archStr, 'alphanum' ) ) = '';
ExtTable.( [ 'mex', archStr ] ) = [ { s( i ).ext }, slibs{ : } ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpq5Ohg2.p.
% Please follow local copyright laws when handling this file.

