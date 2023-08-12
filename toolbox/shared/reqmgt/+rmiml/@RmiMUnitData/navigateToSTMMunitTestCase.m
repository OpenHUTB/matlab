function success = navigateToSTMMunitTestCase( filePath, bookmarkId )



R36
filePath char;
bookmarkId char;
end 

success = false;%#ok<NASGU>


positions = slreq.idToRange( filePath, bookmarkId );
[ procedureNames, isFileLevel ] = rmiml.RmiMUnitData.getTestNamesUnderRange( filePath, positions );



if ~stm.internal.isTestFileOpen( filePath )
sltest.testmanager.load( filePath );
end 

if isFileLevel
testIds = sltest.internal.getTestIdsFromTestNameAndTestFile(  ...
rmiml.RmiMUnitData.getTestClassName( filePath ),  ...
filePath );

testProps = stm.internal.getTestProperty( testIds( 1 ), 'testsuite' );
else 
testIds = sltest.internal.getTestIdsFromTestNameAndTestFile( procedureNames{ 1 }, filePath );
testProps = stm.internal.getTestProperty( testIds( 1 ), 'testcase' );
end 


callback = @(  )stm.internal.openTestCase( filePath, testProps.uuid );
sltest.internal.invokeFunctionAfterWindowRenders( callback );

success = true;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpz_6Iy5.p.
% Please follow local copyright laws when handling this file.

