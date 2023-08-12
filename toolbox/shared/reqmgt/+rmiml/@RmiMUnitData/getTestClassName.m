function testClassName = getTestClassName( fileName )







R36
fileName char{ mustBeNonempty };
end 

suites = matlab.unittest.TestSuite.fromFile( fileName );
if numel( suites ) > 0
testClassName = suites( 1 ).TestClass;
end 
if isempty( testClassName )


testClassName = '';
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpp5KSuT.p.
% Please follow local copyright laws when handling this file.

