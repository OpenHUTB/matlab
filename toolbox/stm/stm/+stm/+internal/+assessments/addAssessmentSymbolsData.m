



















function [ mappingInfo, symbolNameMap ] = addAssessmentSymbolsData( targetTestCaseID, symbolsArray, updateJSON, symbolNameMap )

R36
targetTestCaseID( 1, 1 )double
symbolsArray( 1, : )sltest.testmanager.AssessmentSymbol
updateJSON( 1, 1 ){ mustBeLogical }
symbolNameMap containers.Map = containers.Map
end 

assessmentID = stm.internal.getAssessmentsID( targetTestCaseID );
assessmentsJSON = stm.internal.getAssessmentsInfo( assessmentID );

currentNames = [  ];
if ~isempty( assessmentsJSON )
assessmentsData = jsondecode( assessmentsJSON );
assessmentsStruct = stm.internal.getAssessmentsDefinitionHelper( assessmentsJSON );
if ~isempty( assessmentsStruct.symbolsDefinition )
currentNames = cellfun( @( x )x.Name, assessmentsStruct.symbolsDefinition, 'UniformOutput', false );
end 
else 
assessmentsData.AssessmentsInfo = [  ];
assessmentsData.MappingInfo = [  ];
assessmentsData.MappingInfo2 = [  ];
end 

namePrefix = 'Symbol';
mappingInfo = [  ];
for i = 1:length( symbolsArray )
if updateJSON || ~isKey( symbolNameMap, symbolsArray( i ).Name )
symbolStructArray = stm.internal.assessments.getAssessmentStructArray( symbolsArray( i ).TestCaseID, symbolsArray( i ).ID, "MappingInfo" );


if ~isempty( assessmentsData.MappingInfo ) &&  ...
any( ismember( currentNames, symbolsArray( i ).Name ) )


newName = stm.internal.assessments.getNewLabel( string( currentNames ), namePrefix );
symbolNameMap( symbolStructArray{ 1 }.value ) = newName;
symbolStructArray{ 1 }.value = newName;
else 
symbolNameMap( symbolStructArray{ 1 }.value ) = symbolStructArray{ 1 }.value;
end 


if ~isempty( assessmentsData.MappingInfo )
symbolStructArray = stm.internal.assessments.updateAssessmentStructIDs( symbolStructArray, assessmentsData.MappingInfo{ end  }.id );
end 
mappingInfo = [ mappingInfo;symbolStructArray ];
currentNames{ end  + 1 } = char( symbolStructArray{ 1 }.value );
end 
end 

if ( updateJSON )
assessmentsData.MappingInfo = [ assessmentsData.MappingInfo;mappingInfo ];
updatedAssessJSON = jsonencode( assessmentsData );
stm.internal.setAssessmentsInfo( assessmentID, updatedAssessJSON );
end 

end 



function mustBeLogical( value )
if ~islogical( value )
error( message( 'stm:general:ExpectedLogicalScalar' ) );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpStEvHq.p.
% Please follow local copyright laws when handling this file.

