function success = navigateToSTMMunitTestCase( filePath, bookmarkId )

arguments
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
