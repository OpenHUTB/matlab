function newWorkingEvolutionInfo = create( obj, evolutionToCopy )





R36
obj
evolutionToCopy = evolutions.model.EvolutionInfo.empty( 1, 0 );
end 

firstEvolution = isempty( obj.WorkingEvolution );


inputData = struct( 'Project', obj.Project,  ...
'ArtifactRootFolder', convertStringsToChars( obj.ArtifactRootFolder ),  ...
'Name', evolutions.internal.utils.getActiveEvolutionName( obj.Project ) );
inputData.Profiles = obj.Profiles;


mfModel = mf.zero.Model( obj.Constellation );
newWorkingEvolutionInfo = evolutions.model.EvolutionInfo.createObject( mfModel, inputData );


obj.insert( newWorkingEvolutionInfo );

if firstEvolution

obj.RootEvolution = newWorkingEvolutionInfo;
end 

if ( ~isempty( evolutionToCopy ) )

bfiToAdd = evolutions.internal.utils ...
.getBaseToArtifactsKeyValues( evolutionToCopy );
newWorkingEvolutionInfo.addBaseFile( bfiToAdd );
end 


obj.WorkingEvolution = newWorkingEvolutionInfo;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLYyhDo.p.
% Please follow local copyright laws when handling this file.

