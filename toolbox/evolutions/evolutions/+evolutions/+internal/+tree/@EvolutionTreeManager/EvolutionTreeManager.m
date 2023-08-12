classdef EvolutionTreeManager <  ...
evolutions.internal.datautils.SerializedAbstractInfoManager






properties 
Profiles
end 

methods ( Access = public )

function obj = EvolutionTreeManager( project, rootFolder, artifactFolder )
R36
project
rootFolder = project.RootFolder;
artifactFolder = 'EvolutionTrees';
end 
obj = obj@evolutions.internal.datautils.SerializedAbstractInfoManager(  ...
'evolutions.model.EvolutionTreeInfo', project,  ...
rootFolder, artifactFolder );


obj.Profiles = evolutions.internal.utils.makeCell( evolutions ...
.internal.stereotypes.getDefaultProfileName );
end 

epi = create( obj, name )
epi = load( obj, varargin )
save( obj )
deleteEvolutionTree( obj, eti )
loadArtifacts( obj )
refreshEti( obj, eti )
updateConstellationWithBackups( obj, constellation )
syncTreesWithProject( obj )
insert( obj, eti );


eti = readDataFile( obj, constellation, xmlFile )
end 

methods ( Access = protected )
infos = getValidInfos( obj )
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_VOOWm.p.
% Please follow local copyright laws when handling this file.

