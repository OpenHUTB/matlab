classdef Helper


methods ( Static )
function objArray = copyTests( objArray, targetObj )

p = inputParser;
p.addRequired( 'objArray', @( x )validateattributes( x,  ...
{ 'sltest.testmanager.TestCase', 'sltest.testmanager.TestSuite' },  ...
{ 'nonempty', 'vector' } ) );
p.addRequired( 'targetObj', @( x )validateattributes( x,  ...
{ 'sltest.testmanager.TestSuite', 'sltest.testmanager.TestFile' },  ...
{ 'nonempty', 'scalar' } ) );
p.parse( objArray, targetObj );


expectingNewSuites = isa( targetObj, 'sltest.testmanager.TestFile' ) ...
 || isa( objArray, 'sltest.testmanager.TestSuite' );
if expectingNewSuites
origIDs = stm.internal.getTestSuites( targetObj.getID );
else 
origIDs = stm.internal.getTestCases( targetObj.getID );
end 

stm.internal.copyTests( objArray.getID, targetObj.getID );

if expectingNewSuites
allObjs = targetObj.getTestSuites;
else 
allObjs = targetObj.getTestCases;
end 


newObjs = allObjs( length( origIDs ) + 1:end  );
if expectingNewSuites && isa( objArray, 'sltest.testmanager.TestCase' )


objArray = newObjs.getTestCases;
else 
objArray = newObjs;
end 
end 

function ret = getTestFile( obj )
R36
obj( 1, 1 )sltest.testmanager.Test;
end 
tfID = stm.internal.getTestCaseProperty( obj.getID, 'TestFileID' );
ret = sltest.testmanager.TestFile( "", false, true, tfID );
end 

function ret = getTestPath( obj )
R36
obj( 1, 1 )sltest.testmanager.Test;
end 
ret = stm.internal.getTestCaseProperty( obj.getID, 'TestPath' );
end 

function ret = reformatRequirements( requirements )
oneReq = struct( 'description', '',  ...
'doc', '',  ...
'docurl', '',  ...
'reqsys', '',  ...
'rid', '' );
ret = repmat( oneReq, length( requirements ), 1 );
for k = 1:length( requirements )
ret( k ).description = requirements( k ).description;
ret( k ).doc = requirements( k ).document;
ret( k ).docurl = requirements( k ).docURL;
ret( k ).reqsys = requirements( k ).reqSys;
ret( k ).rid = requirements( k ).reqId;
end 
end 

function ret = getRequirements( obj )
if isa( obj, 'sltest.testmanager.Test' )
filePath = stm.internal.getTestCaseProperty( obj.getID, 'Location' );
if endsWith( filePath, '.m', 'IgnoreCase', true )
checkRequirements = true;

stm.internal.updateRequirementsForTestName( filePath, obj.Name );
else 
checkRequirements = stm.internal.getTestCaseProperty( obj.getID, 'HasRequirementLinks' );
end 
if checkRequirements
testUUID = stm.internal.getTestCaseProperty( obj.getID, 'UUID' );
testName = stm.internal.getTestCaseProperty( obj.getID, 'Name' );
ret = stm.internal.util.getReqs( filePath, testUUID, testName );
else 
ret = repmat( struct( 'url', '', 'description', '' ), 0, 1 );
end 
end 
end 

function coverageSettings = getCoverageSettings( tcID, isTestFile )
[ coverageID, coverageMetricsID ] = stm.internal.getCoverageID( tcID );
coverageSettings = sltest.testmanager.CoverageSettings(  ...
coverageID, coverageMetricsID, isTestFile, coverageID > 0 );
end 

function options = getOptions( tcID, isTestFile )
optionsID = stm.internal.getOptionsID( tcID );
options = sltest.testmanager.Options(  ...
optionsID, isTestFile );
end 

function pOvrObjs = getParameterOverride( ids )

pOvrObjs( numel( ids ) ) = sltest.testmanager.ParameterOverride;
sltest.internal.Helper.setID( pOvrObjs, ids );
end 
function out = getTestInput( id )
out = sltest.testmanager.TestInput( id );
end 

function out = getBaselineCriteria( id )
out = sltest.testmanager.BaselineCriteria( id );
end 

function exlOpts = getExcelOptions( srcID, type )
optIDs = stm.internal.getExcelOptionsIDs( srcID, type );
exlOpts = [ sltest.testmanager.ExcelSpecifications.empty,  ...
arrayfun( @( x )sltest.testmanager.ExcelSpecifications( x ), optIDs ) ];
end 

function ret = cppOutcomeToMatlabOutcome( outcome )
if outcome == 6

ret = sltest.testmanager.TestResultOutcomes.Disabled;
elseif outcome == 0

ret = sltest.testmanager.TestResultOutcomes.Incomplete;
elseif outcome == 2

ret = sltest.testmanager.TestResultOutcomes.Passed;
elseif outcome == 1

ret = sltest.testmanager.TestResultOutcomes.Running;
elseif outcome == 7

ret = sltest.testmanager.TestResultOutcomes.Untested;
elseif outcome == 5

ret = sltest.testmanager.TestResultOutcomes.Scheduled;
else 

ret = sltest.testmanager.TestResultOutcomes.Failed;
end 
end 

function addAdapterInfoToTable( testReportObj, resultObj, table )
import mlreportgen.dom.*;
onerow = TableRow(  );
str = getString( message( 'stm:ReportContent:Field_Test_Data_Path' ) );
text = Text( str );
text.Style = [ text.Style, { FontSize( testReportObj.BodyFontSize ), Color( testReportObj.BodyFontColor ) } ];
onerow.append( TableEntry( text ) );

str = char( resultObj.TestDataPath );
entry = sltest.testmanager.ReportUtility.genDefaultTableEntry( testReportObj, str );
onerow.append( entry );
append( table, onerow );

onerow = TableRow(  );
str = getString( message( 'stm:ReportContent:Field_Adapter' ) );
text = Text( str );
text.Style = [ text.Style, { FontSize( testReportObj.BodyFontSize ), Color( testReportObj.BodyFontColor ) } ];
onerow.append( TableEntry( text ) );

str = char( resultObj.Adapter );
entry = sltest.testmanager.ReportUtility.genDefaultTableEntry( testReportObj, str );
onerow.append( entry );
append( table, onerow );
end 


function resultSet = mergeCoverage( objArray )
R36
objArray( :, 1 )sltest.testmanager.ResultSet{ mustBeNonempty };
end 

resultID = stm.internal.util.mergeCoverage( objArray.getID );


resultSet = sltest.testmanager.ResultSet( [  ], resultID );
end 

function setID( objs, ids )
ids = num2cell( ids );
[ objs.id ] = ids{ : };
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpkUbTvV.p.
% Please follow local copyright laws when handling this file.

