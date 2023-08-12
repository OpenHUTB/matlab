










function addAssessmentsData( targetTestCaseID, assessmentArray, copySymbols )

R36
targetTestCaseID( 1, 1 )double
assessmentArray( 1, : )sltest.testmanager.Assessment
copySymbols( 1, 1 )logical
end 


assessmentID = stm.internal.getAssessmentsID( targetTestCaseID );
assessmentsJSON = stm.internal.getAssessmentsInfo( assessmentID );
symbolNameMap = containers.Map;

currentNames = [  ];
if ~isempty( assessmentsJSON )
assessmentsData = jsondecode( assessmentsJSON );
assessmentsStruct = stm.internal.getAssessmentsDefinitionHelper( assessmentsJSON );
if ~isempty( assessmentsStruct.assessmentsDefinition )
currentNames = { assessmentsStruct.assessmentsDefinition.assessmentName };
end 
else 
assessmentsData.AssessmentsInfo = [  ];
assessmentsData.MappingInfo = [  ];
assessmentsData.MappingInfo2 = [  ];
end 

namePrefix = 'Assessment';
for i = 1:length( assessmentArray )
assessStructArray = stm.internal.assessments.getAssessmentStructArray( assessmentArray( i ).TestCaseID, assessmentArray( i ).ID, "AssessmentsInfo" );


if ~isempty( assessmentsData.AssessmentsInfo ) &&  ...
any( ismember( currentNames, assessmentArray( i ).Name ) )



assessStructArray = stm.internal.assessments.updateAssessmentStructIDs( assessStructArray, assessmentsData.AssessmentsInfo{ end  }.id );



newName = stm.internal.assessments.getNewLabel( string( currentNames ), namePrefix );
assessStructArray{ 1 }.assessmentName = newName;
end 

sourceAssessID = assessmentArray( i ).ID;
sourceTestCaseID = assessmentArray( i ).TestCaseID;



copyReqLinks( assessStructArray, targetTestCaseID, sourceTestCaseID, sourceAssessID );




if copySymbols
symbolsArray = assessmentArray( i ).Symbols;
if ~isempty( symbolsArray )
[ mappingInfo, symbolNameMap ] = stm.internal.assessments.addAssessmentSymbolsData( targetTestCaseID, symbolsArray, false, symbolNameMap );
assessStructArray = updateSymbolNames( assessStructArray, symbolNameMap );
assessmentsData.MappingInfo = [ assessmentsData.MappingInfo;mappingInfo ];
end 
end 

assessmentsData.AssessmentsInfo = [ assessmentsData.AssessmentsInfo;assessStructArray ];
updatedAssessJSON = jsonencode( assessmentsData );
stm.internal.setAssessmentsInfo( assessmentID, updatedAssessJSON );
currentNames{ end  + 1 } = char( assessStructArray{ 1 }.assessmentName );
end 

end 



function copyReqLinks( assessStructArray, targetTestCaseID, sourceTestCaseID, sourceAssessID )
for i = 1:length( assessStructArray )
if assessStructArray{ i }.parent ==  - 1

targetTestFile = stm.internal.getTestCaseProperty( targetTestCaseID, 'Location' );
sourceTestFile = stm.internal.getTestCaseProperty( sourceTestCaseID, 'Location' );

testCaseObj = sltest.testmanager.TestCase( [  ], targetTestCaseID );
targetAssessUUID = testCaseObj.AssessmentsUUID;
targetReqAssessUUID = [ targetAssessUUID, ':', num2str( assessStructArray{ i }.id ) ];

sourceAssessUUID = stm.internal.getAssessmentsUUID( sourceTestCaseID );
sourceReqAssessUUID = [ sourceAssessUUID, ':', num2str( sourceAssessID ) ];

stm.internal.util.copyRequirementLinks( targetTestFile, targetReqAssessUUID, sourceTestFile, sourceReqAssessUUID, false );
end 
end 
end 



function assessStructArray = updateSymbolNames( assessStructArray, symbolNameMap )
jsonString = jsonencode( assessStructArray );
origSyms = keys( symbolNameMap );
for i = 1:length( origSyms )
if ~isequal( origSyms{ i }, symbolNameMap( origSyms{ i } ) )
jsonString = replace( jsonString, origSyms{ i }, symbolNameMap( origSyms{ i } ) );
end 
end 
assessStructArray = jsondecode( jsonString );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpnxfySS.p.
% Please follow local copyright laws when handling this file.

