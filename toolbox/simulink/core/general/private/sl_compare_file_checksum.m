function [ oFileExists, oSameChecksum ] = sl_compare_file_checksum( iFile, iChecksum, varargin )










oFileExists = false;
oSameChecksum = false;

[ file, foundFile ] = sl_get_file_ignoring_builtins( iFile, varargin{ : } );

if foundFile
oFileExists = true;

currentChecksum = file2hash( file );
oSameChecksum = strcmp( currentChecksum, iChecksum );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMwhxcA.p.
% Please follow local copyright laws when handling this file.

