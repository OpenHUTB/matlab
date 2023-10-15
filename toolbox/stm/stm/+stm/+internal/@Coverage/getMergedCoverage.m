function resultStruct = getMergedCoverage( models, testCaseResults )

arguments
    models{ mustBeText }
    testCaseResults
end

models = convertCharsToStrings( models );
selectedRunIDs = { testCaseResults.TestCaseResultUuid };


resultUUIDs = unique( { testCaseResults.ResultSetUuid } );
inputResultSets = cellfun( @( uuid )getResultFromUUID( uuid ), resultUUIDs );

resultStruct = struct( "Model", {  },  ...
    "CoverageData", {  }, "MergedTestCaseResults", {  } );

if ( length( resultUUIDs ) == 1 )
    for k = 1:numel( models )

        model = models( k );


        cvdo = locGetCoverageResults( inputResultSets, model, selectedRunIDs );



        mergedTestCaseResults = testCaseResults;


        resultStruct( k ).Model = models( k );
        resultStruct( k ).CoverageData = cvdo;
        resultStruct( k ).MergedTestCaseResults = mergedTestCaseResults;

    end

else


    mergedResultSet = sltest.internal.Helper.mergeCoverage( inputResultSets );
    guard = onCleanup( @(  )mergedResultSet.remove(  ) );

    for k = 1:numel( models )

        model = models( k );




        cvdo = locGetCoverageResults( mergedResultSet, model, selectedRunIDs );



        mergedTestCaseResults = getMergedTestCases( cvdo );


        resultStruct( k ).Model = models( k );
        resultStruct( k ).CoverageData = cvdo;
        resultStruct( k ).MergedTestCaseResults = mergedTestCaseResults;
    end
end
end

function rsObj = getResultFromUUID( resultUUID )
id = stm.internal.getResultSetIDsFromUUID( resultUUID );
id = id( end  );
rsObj = sltest.testmanager.TestResult.getResultFromID( id );
end

function testCaseResults = getMergedTestCases( cvdo )
if isempty( cvdo )
    testCaseResults = [  ];
    return ;
end

ati = cvdo.aggregatedTestInfo;
if isempty( ati )

    testRunInfo = { cvdo.testRunInfo };
else
    testRunInfo = { ati.testRunInfo };
end

testCaseResultUuid = cellfun( @( runInfo )runInfo.runId, testRunInfo, 'UniformOutput', false );
resultSetUuid = cellfun( @getParentResultSetUUID, testCaseResultUuid, 'UniformOutput', false );
testCaseResults = struct( 'ResultSetUuid', resultSetUuid,  ...
    'TestCaseResultUuid', testCaseResultUuid );
end

function uuid = getParentResultSetUUID( tcrUUID )
testobj = sltest.testmanager.TestResult.getResultFromUUID( tcrUUID );
while ( class( testobj ) ~= "sltest.testmanager.ResultSet" )
    testobj = testobj.Parent;
end
uuid = testobj.UUID;
end

function cvd = locGetCoverageResults( rs, model, selectedRunIDs )
cvd = [  ];
load_system( model );

cvResults = stm.internal.getTestManagerCoverageResults( rs.getResultID, model );
if isempty( cvResults )
    return ;
end
cvResults_NormalSimsIdx = strcmpi( { cvResults.SimMode }, 'Normal' );
cvResults_Normal = cvResults( cvResults_NormalSimsIdx );

if isempty( cvResults_Normal )
    return ;
end

filenames = stm.internal.getCoverageResults( rs.getResultID, model );
filenames = filenames( cvResults_NormalSimsIdx );

if numel( filenames ) == 1
    fileToLoad = filenames{ 1 };
else



    expChecksum = getCovChecksum( model );
    matchingChecksumIdx = strcmp( { cvResults_Normal.Checksum }, expChecksum );


    filenames = filenames( matchingChecksumIdx );
    if ( numel( filenames ) > 1 )


        cvResults_Matching = cvResults( matchingChecksumIdx );
        releaseList = { cvResults_Matching.Release };
        releaseListSorted = sort( releaseList );
        latestRel = releaseListSorted{ end  };
        matchingReleaseIdx = strcmp( releaseList, latestRel );
        filenames = filenames( matchingReleaseIdx );
    end

    if ( numel( filenames ) == 1 )
        fileToLoad = filenames{ 1 };
    else
        fileToLoad = [  ];
    end

end

cvdTemp = [  ];
if ~isempty( fileToLoad )
    [ ~, cvdTemp ] = cvload( fileToLoad );
end

if isempty( cvdTemp )
    [ errMsg, errId ] = stm.internal.Coverage.getCovErrorMsg( model, 'MergeCoverageFromIncompatibleCvdataError' );
    stm.internal.util.warning( errId, getString( errMsg ) );
else
    cvd = removeUndesiredRuns( cvdTemp{ 1 }, selectedRunIDs );
end
end

function chkString = getCovChecksum( model )
chkString = '';
oldVal_RecordCoverage = get_param( model, 'RecordCoverage' );
oldVal_Dirty = get_param( model, 'Dirty' );
restoreRecordCoverage = onCleanup( @(  )set_param( model, 'RecordCoverage', oldVal_RecordCoverage ) );
restoreDirtyFlag = onCleanup( @(  )set_param( model, 'Dirty', oldVal_Dirty ) );
set_param( model, 'RecordCoverage', 'on' );

SlCov.CoverageAPI.deleteModelcov( model );
SlCov.CoverageAPI.compileForCoverage( model );
checksum = SlCov.CoverageAPI.getChecksum( model );

if ~isempty( checksum )
    chkString = sprintf( '%010d%010d%010d%010d', checksum( 1 ), checksum( 2 ), checksum( 3 ), checksum( 4 ) );
end

end

function cvdOut = removeUndesiredRuns( cvdIn, selectedRunIDs )






cvdOut = cvdIn;

if isempty( cvdIn )
    return ;
end

ati = cvdIn.aggregatedTestInfo;
if isempty( ati )
    return ;
end
testRunInfo = { ati.testRunInfo };
testIDs = cellfun( @( runInfo )runInfo.testId, testRunInfo, 'UniformOutput', false );
runIDs = cellfun( @( runInfo )runInfo.runId, testRunInfo, 'UniformOutput', false );
isRunSelected = ismember( runIDs, selectedRunIDs );
selectedTestIDs = testIDs( isRunSelected );

if ( length( selectedTestIDs ) == length( unique( selectedTestIDs ) ) )

    keepIdx = find( isRunSelected );
else

    startDates = cellfun( @( runInfo )getRunStartTime( runInfo ), testRunInfo, 'UniformOutput', false );
    [ ~, sortIdx ] = sort( [ startDates{ : } ], 'ascend', 'MissingPlacement', 'first' );
    isRunSelected_sorted = isRunSelected( sortIdx );
    sortIdx_sel_only = sortIdx( isRunSelected_sorted );
    sortedTestIDs = testIDs( sortIdx_sel_only );
    [ ~, uniqueIdx ] = unique( sortedTestIDs, 'last' );
    uniqueIdx = sort( uniqueIdx );
    keepIdx = sortIdx_sel_only( uniqueIdx );
end


if ( length( keepIdx ) < length( runIDs ) )
    cvdOut = cvdIn.getAggregatedSubset( keepIdx );
end
end

function startTime = getRunStartTime( testRunInfo )
try
    runUUID = testRunInfo.runId;
    startTime = sltest.testmanager.TestResult.getResultFromUUID( runUUID ).StartTime;
catch
    startTime = NaT;
end
end
