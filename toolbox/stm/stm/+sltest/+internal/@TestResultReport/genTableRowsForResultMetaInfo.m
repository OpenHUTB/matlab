function rowList = genTableRowsForResultMetaInfo( obj, result )

arguments
obj( 1, 1 ){ mustBeA( obj, [ "sltest.internal.TestResultReport", "sltest.testmanager.TestResultReport" ] ) };
result sltest.testmanager.ReportUtility.ReportResultData;
end 
import mlreportgen.dom.*;

resultObj = result.Data;
rowList = [  ];


onerow = TableRow(  );
str = getString( message( 'stm:ReportContent:Field_ResultType' ) );
text = Text( str );
sltest.testmanager.ReportUtility.setTextStyle( text, obj.BodyFontName, obj.BodyFontSize, obj.BodyFontColor, false, false );
onerow.append( TableEntry( Paragraph( text ) ) );

resultType = sltest.testmanager.ReportUtility.getTypeOfTestResult( result.Data );
str = getString( message( 'stm:ReportContent:Label_ExecutionResult' ) );

if ( resultType == sltest.testmanager.TestResultTypes.ResultSet )
str = getString( message( 'stm:ReportContent:Label_ResultSet' ) );
elseif ( resultType == sltest.testmanager.TestResultTypes.TestFileResult )
str = getString( message( 'stm:ReportContent:Label_TestFileResult' ) );
elseif ( resultType == sltest.testmanager.TestResultTypes.TestSuiteResult )
str = getString( message( 'stm:ReportContent:Label_TestSuiteResult' ) );
elseif ( resultType == sltest.testmanager.TestResultTypes.TestCaseResult )
str = getString( message( 'stm:ReportContent:Label_TestCaseResult' ) );
elseif ( resultType == sltest.testmanager.TestResultTypes.TestIterationResult )
str = getString( message( 'stm:ReportContent:Label_TestIterationResult' ) );
end 
text1 = text.clone(  );
text1.Content = str;
onerow.append( TableEntry( Paragraph( text1 ) ) );
rowList = [ rowList;onerow ];


onerow = TableRow(  );
text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Field_Parent' ) );
onerow.append( TableEntry( text1 ) );

entry = TableEntry(  );
if ( ~isempty( result.ParentResultName ) && ~isempty( result.ParentResultUID ) )

inlnkObj = InternalLink( result.ParentResultUID, result.ParentResultName );
tmpTxt = inlnkObj.Children( 1 );
sltest.testmanager.ReportUtility.setTextStyle( tmpTxt, obj.BodyFontName, obj.BodyFontSize, 'blue', false, false );
para = Paragraph( inlnkObj );
append( entry, para );
else 
text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Label_None' ) );
append( entry, text1 );
end 
onerow.append( entry );
rowList = [ rowList;onerow ];


onerow = TableRow(  );
text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Field_StartTime' ) );
onerow.append( TableEntry( text1 ) );

text1 = text.clone(  );
text1.Content = char( resultObj.StartTime );
onerow.append( TableEntry( text1 ) );
rowList = [ rowList;onerow ];


onerow = TableRow(  );
text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Field_EndTime' ) );
onerow.append( TableEntry( text1 ) );

text1 = text.clone(  );
text1.Content = char( resultObj.StopTime );
onerow.append( TableEntry( text1 ) );
rowList = [ rowList;onerow ];


onerow = TableRow(  );
text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Field_Outcome' ) );
onerow.append( TableEntry( text1 ) );

if ( resultType == sltest.testmanager.TestResultTypes.TestCaseResult ||  ...
resultType == sltest.testmanager.TestResultTypes.TestIterationResult )
text1 = sltest.testmanager.ReportUtility.genTextForTestCaseOutcome( obj, resultObj.Outcome );
onerow.append( TableEntry( text1 ) );
else 
cM = obj.getCountMetricsOfResult( result.Data );
str1 = getString( message( 'stm:ReportContent:Label_NoTestResults' ) );
if ( cM.numOfResults > 0 )
str1 = sprintf( '%s %d', getString( message( 'stm:ReportContent:Field_Total' ) ), cM.numOfResults );
end 
text1 = text.clone(  );
text1.Content = str1;
para = sltest.testmanager.ReportUtility.genParaDefaultStyle( text1 );

if ( cM.numOfPassed > 0 )
tmpText = text.clone(  );
tmpText.Content = ', ';
append( para, tmpText );

str2 = sprintf( '%s %d', getString( message( 'stm:ReportContent:Field_Passed' ) ), cM.numOfPassed );
text2 = text.clone(  );
text2.Content = str2;
sltest.testmanager.ReportUtility.setTextStyle( text2, obj.BodyFontName, obj.BodyFontSize, 'green', false, false );
append( para, text2 );
end 

if ( cM.numOfFailed > 0 )
tmpText = text.clone(  );
tmpText.Content = ', ';
append( para, tmpText );

str3 = sprintf( '%s %d', getString( message( 'stm:ReportContent:Field_Failed' ) ), cM.numOfFailed );
text3 = text.clone(  );
text3.Content = str3;
sltest.testmanager.ReportUtility.setTextStyle( text3, obj.BodyFontName, obj.BodyFontSize, 'red', false, false );
append( para, text3 );
end 

if ( cM.numOfDisabled > 0 )
tmpText = text.clone(  );
tmpText.Content = ', ';
append( para, tmpText );

str3 = sprintf( '%s %d', getString( message( 'stm:ReportContent:Field_Disabled' ) ), cM.numOfDisabled );
text3 = text.clone(  );
text3.Content = str3;
sltest.testmanager.ReportUtility.setTextStyle( text3, obj.BodyFontName, obj.BodyFontSize, 'grey', false, false );
append( para, text3 );
end 

if ( cM.numOfIncomplete > 0 )
tmpText = text.clone(  );
tmpText.Content = ', ';
append( para, tmpText );

str = sprintf( '%s %d', getString( message( 'stm:ReportContent:Field_Incomplete' ) ), cM.numOfIncomplete );
text4 = text.clone(  );
text4.Content = str;
sltest.testmanager.ReportUtility.setTextStyle( text4, obj.BodyFontName, obj.BodyFontSize, 'black', false, false );
append( para, text4 );
end 
onerow.append( TableEntry( para ) );
end 
rowList = [ rowList;onerow ];


if ( resultObj.Outcome == sltest.testmanager.TestResultOutcomes.Failed &&  ...
( resultType == sltest.testmanager.TestResultTypes.TestCaseResult ||  ...
resultType == sltest.testmanager.TestResultTypes.TestIterationResult ) )

onerow = TableRow(  );
errorStr = stm.internal.getTcrProperty( resultObj.getResultID, 'CauseOfFailure' );

text1 = text.clone(  );
text1.Content = getString( message( 'stm:ReportContent:Field_CauseOfFailure' ) );
onerow.append( TableEntry( text1 ) );

text1 = text.clone(  );
text1.Content = errorStr;
sltest.testmanager.ReportUtility.setTextStyle( text1, obj.BodyFontName, obj.BodyFontSize, 'red', false, false );
onerow.append( TableEntry( text1 ) );

rowList = [ rowList;onerow ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpm05kyv.p.
% Please follow local copyright laws when handling this file.

