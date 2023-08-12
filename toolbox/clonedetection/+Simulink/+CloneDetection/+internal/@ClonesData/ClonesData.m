classdef ClonesData < Simulink.CloneDetection.internal.ClonesDataBase




properties 
FindClonesRecursivelyInFolders;
end 
methods ( Static )
function obj = getActiveInstance( system )
obj = get_param( system, 'CloneDetectionUIObj' );
end 
end 

methods ( Access = 'public' )

detectClonesCallBack( this );
cloneReplaceResults = refactorCallBack( this );
populateExactAndSimilarCloneResults( this, m2mObj );


function this = ClonesData( modelName )
R36
modelName = ''
end 
this = this@Simulink.CloneDetection.internal.ClonesDataBase( modelName );
this.initClonesData(  );
end 

function initClonesData( this )
this.FindClonesRecursivelyInFolders = true;
end 


function populateExclusions( this )
this.excludeCloneDetection = [  ];
if isempty( this.model )
return ;
end 

this.excludeCloneDetection = this.getExclusions( this.model );
this.totalBlocks = slEnginePir.util.getNumberOfBlocks( this.model );
if ~isa( this.m2mObj, 'slEnginePir.acrossModelGraphicalCloneDetection' )
refModels = this.m2mObj.refModels;
for i = 1:length( refModels )
this.excludeCloneDetection = [ this.excludeCloneDetection ...
, this.getExclusions( char( refModels( i ) ) ) ];
this.totalBlocks = this.totalBlocks + slEnginePir.util.getNumberOfBlocks( char( refModels( i ) ) );
end 
end 
for i = 1:length( this.excludeCloneDetection )
this.blockPathCategoryMap( this.excludeCloneDetection{ i } ) =  ...
struct( 'CloneGroupKey', 'Exclusion', 'CloneGroupName', '' );
if getSimulinkBlockHandle( this.excludeCloneDetection{ i } ) ~=  - 1 && strcmp( get_param( this.excludeCloneDetection{ i }, 'BlockType' ), 'ModelReference' )

this.excludeCloneDetection{ i } = get_param( this.excludeCloneDetection{ i }, 'ModelName' );
end 
end 
end 

function explicitlyLoadedModels = populateExclusionsForAcrossModels( this )
this.excludeCloneDetection = [  ];
this.totalBlocks = 0;

for modelIndex = 1:length( this.m2mObj.allmodels )
modelName = this.m2mObj.allmodels{ modelIndex };
excludedBlocks = this.getExclusions( modelName );
totalBlocksOfModel = slEnginePir.util.getNumberOfBlocks( modelName );
this.totalBlocks = this.totalBlocks + totalBlocksOfModel;
for blockIndex = 1:length( excludedBlocks )
this.blockPathCategoryMap( excludedBlocks{ blockIndex } ) = 'Exclusion';
if strcmp( get_param( excludedBlocks{ blockIndex }, 'BlockType' ), 'ModelReference' )

excludedBlocks{ blockIndex } = get_param( excludedBlocks{ blockIndex }, 'ModelName' );
end 
end 

excludedBlocksInModelReferences = {  };
if ~( this.excludeModelReferences )
[ ~, refModels, ~, ~, explicitlyLoadedModels ] =  ...
slEnginePir.all_referlinked_blk( modelName, [  ], {  } );
excludedBlocksInModelReferences = cell( 1, length( refModels ) );
for refModelIndex = 1:length( refModels )
excludedBlocksInModelReferences{ refModelIndex } =  ...
this.getExclusions( char( refModels( refModelIndex ) ) );
totalBlocksRefModel = slEnginePir.util.getNumberOfBlocks( char( refModels( refModelIndex ) ) );
this.totalBlocks = this.totalBlocks + totalBlocksRefModel;
end 
end 

this.excludeCloneDetection = [ this.excludeCloneDetection ...
, excludedBlocks, excludedBlocksInModelReferences ];
this.excludeCloneDetection = this.excludeCloneDetection( ~cellfun( @isempty,  ...
this.excludeCloneDetection ) );
end 
end 

function overWriteBlockPathCategoryMap( this, cloneResults, exclusionList )
blockMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
if ~isempty( cloneResults )
for exactGroupIndex = 1:length( cloneResults.exact )
nodeChildrenArray = cloneResults.Before{ cloneResults.exact{ exactGroupIndex }.index };
for childIdx = 1:length( nodeChildrenArray )
groupNameKey = [ 'Exact-CloneGroup-', num2str( exactGroupIndex ) ];
message = [ DAStudio.message( 'sl_pir_cpp:creator:sysclonedetc_PrefixExact' ), ' ',  ...
DAStudio.message( 'sl_pir_cpp:creator:sysclonedetc_Subsystemclonegroup', exactGroupIndex ) ];
blockMap( nodeChildrenArray{ childIdx } ) = struct( 'CloneGroupKey', groupNameKey,  ...
'CloneGroupName', message );
end 
end 
for similarGroupIndex = 1:length( cloneResults.similar )
nodeChildrenArray = cloneResults.Before{ cloneResults.similar{ similarGroupIndex }.index };
for childIdx = 1:length( nodeChildrenArray )
groupNameKey = [ 'Similar-CloneGroup-', num2str( similarGroupIndex ) ];
message = [ DAStudio.message( 'sl_pir_cpp:creator:sysclonedetc_PrefixSimilar' ), ' ',  ...
DAStudio.message( 'sl_pir_cpp:creator:sysclonedetc_Subsystemclonegroup', similarGroupIndex ) ];
blockMap( nodeChildrenArray{ childIdx } ) = struct( 'CloneGroupKey', groupNameKey,  ...
'CloneGroupName', message );
end 
end 
end 
for exclusionIdx = 1:length( exclusionList )
blockMap( exclusionList{ exclusionIdx } ) = struct( 'CloneGroupKey', 'Exclusion', 'CloneGroupName', '' );
end 
this.blockPathCategoryMap = blockMap;
end 
end 

methods ( Access = 'protected' )
function constructHelperMaps( obj )
obj.constructHelperMaps@Simulink.CloneDetection.internal.ClonesDataBase;
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpraRrHv.p.
% Please follow local copyright laws when handling this file.

