


function tcArray = getTestCases( obj )
R36
obj( 1, 1 ){ mustBeA( obj, [ "sltest.testmanager.TestFile", "sltest.testmanager.TestSuite" ] ) };
end 

tcids = stm.internal.getTestCases( obj.getID );
tcArray = sltest.testmanager.TestCase.empty( 1, 0 );
for idx = 1:length( tcids )
tcArray( idx ) = sltest.testmanager.TestCase( obj, tcids( idx ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7o1F8_.p.
% Please follow local copyright laws when handling this file.

