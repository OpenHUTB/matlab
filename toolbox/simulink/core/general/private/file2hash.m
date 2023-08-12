function result = file2hash( aFile )






R36
aFile{ mustBeTextScalar, mustBeFile }
end 

result = builtin( '_getFileChecksum', convertStringsToChars( aFile ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUGC4jL.p.
% Please follow local copyright laws when handling this file.

