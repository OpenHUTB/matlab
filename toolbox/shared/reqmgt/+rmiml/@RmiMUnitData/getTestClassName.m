function testClassName = getTestClassName( fileName )

arguments
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

