function tf = isGenericMUnitFile( fileName )




R36
fileName string{ mustBeNonempty };
end 

[ ~, ~, fileExt ] = fileparts( fileName );
tf = false;

if fileExt == ".m"
try 
suite = matlab.unittest.TestSuite.fromFile( fileName );








tf = isa( suite, 'matlab.unittest.Test' );
catch 
tf = false;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpiPsupk.p.
% Please follow local copyright laws when handling this file.

