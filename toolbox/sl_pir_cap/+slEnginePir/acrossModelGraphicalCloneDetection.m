







classdef acrossModelGraphicalCloneDetection < handle
properties ( Access = 'public' )
allmodels;
exclusionList;
clonepattern;
creator;
cleanup;
cloneresult;
includeLib;
excluded_sysclone;
ignoreSignalName;
ignoreBlockProperty;
IncludeCommentedRegion = true;
ModelReferences = {  };
LinkedLibraries = {  };
model;
mdlName;
m2m_dir;
loadedModels;
isReplaceExactCloneWithSubsysRef;
TotalNumberOfBlocks;
libmdls;
enableClonesAnywhere;
end 

properties ( SetAccess = 'public', GetAccess = 'public', Hidden = true )
region2BlockList;
end 

methods ( Access = 'public' )

function this = acrossModelGraphicalCloneDetection( mdlfolder, model,  ...
clonepattern, ignoreSignalName, ignoreBlockProperty,  ...
includeModelReferences, includeLibraryLinks, includeCommentedRegion,  ...
isReplaceExactCloneWithSubsysRef, findClonesRecursivelyInFolders,  ...
enableClonesAnywhere, regionSize, cloneGroupSize )
R36
mdlfolder
model = '';
clonepattern = 'StructuralParameters';
ignoreSignalName = true;
ignoreBlockProperty = true;
includeModelReferences = true;
includeLibraryLinks = true;
includeCommentedRegion = true;
isReplaceExactCloneWithSubsysRef = false;
findClonesRecursivelyInFolders = true;
enableClonesAnywhere = false;
regionSize = 2;
cloneGroupSize = 2;
end 
this.ignoreSignalName = ignoreSignalName;
this.ignoreBlockProperty = ignoreBlockProperty;
if includeCommentedRegion
this.IncludeCommentedRegion = 'on';
else 
this.IncludeCommentedRegion = 'off';
end 

this.enableClonesAnywhere = enableClonesAnywhere;
this.isReplaceExactCloneWithSubsysRef = isReplaceExactCloneWithSubsysRef;
this.TotalNumberOfBlocks = 0;
this.region2BlockList = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
allmodels = getAllModelsUnderFolder( this, mdlfolder,  ...
findClonesRecursivelyInFolders );

if includeModelReferences
for modelIndex = 1:length( allmodels )
localModel = allmodels( modelIndex );
[ ~, modelReferences, ~, ~, explicitlyLoadedModels ] =  ...
slEnginePir.all_referlinked_blk( localModel, [  ], {  }, this.IncludeCommentedRegion );
this.loadedModels = [ this.loadedModels;explicitlyLoadedModels ];
this.ModelReferences = [ this.ModelReferences, modelReferences ];
end 
end 

allmodels = [ allmodels, this.ModelReferences ];


if ~isempty( model )
this.model = get_param( model, 'Handle' );
this.mdlName = get_param( model, 'Name' );
end 



this.allmodels = unique( allmodels );
this.exclusionList = [  ];
this.includeLib = includeLibraryLinks;
this.clonepattern = clonepattern;
this.excluded_sysclone = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );

domainToFindClones = 'GraphicalDomain';
if ~( includeCommentedRegion )
domainToFindClones = 'CompiledDomain';
end 
if ~enableClonesAnywhere
this.creator = this.computeChecksumAndGroupClones( allmodels, clonepattern, domainToFindClones );
else 
this.creator = this.clonesAnywhere( allmodels, clonepattern, 'GraphicalDomain', regionSize,  ...
cloneGroupSize, ignoreSignalName, ignoreBlockProperty, true );
end 


end 

function acrossModelCloneDetectionCleanupFcn( this )
if isvalid( this )
try 
for modelIndex = 1:length( this.allmodels )
mdlname = this.allmodels{ modelIndex };
if bdIsLoaded( mdlname )
close_system( mdlname );
end 
end 
catch ME
disp( ME.message );
end 
end 
end 

function include_sysclones( this, name )
if isKey( this.excluded_sysclone, name )
remove( this.excluded_sysclone, name );
end 
end 

function exclude_sysclones( this, name )
this.excluded_sysclone( name ) = 'unselected';
end 


function isExcluded = is_excluded_sysclone( this, name )
isExcluded = isKey( this.excluded_sysclone, name );
end 





function allmodels = getAllModelsUnderFolder( this, mdlfolder,  ...
findClonesRecursivelyInFolders )

curworkingdir = pwd;
allmodels = [  ];
for folderIndex = 1:length( mdlfolder )
curmdlfolder = mdlfolder{ folderIndex };

cd( curmdlfolder );
if ( findClonesRecursivelyInFolders )
allfiles = dir( '**/*.slx' );
allfiles = [ allfiles;dir( '**/*.mdl' ) ];
else 
allfiles = dir( '*.slx' );
allfiles = [ allfiles;dir( '*.mdl' ) ];
end 


len = length( allfiles );
curallmodels = cell( 1, len );
for j = 1:len
cd( allfiles( j ).folder );
[ ~, modelNameWithoutExtension, ~ ] = fileparts( allfiles( j ).name );
if ~bdIsLoaded( modelNameWithoutExtension )
try 
load_system( fullfile( allfiles( j ).folder, modelNameWithoutExtension ) );
if bdIsLibrary( modelNameWithoutExtension )
continue ;
end 
this.loadedModels = [ this.loadedModels;{ modelNameWithoutExtension } ];
catch 
ExceptionLog = DAStudio.message( 'sl_pir_cpp:creator:ModelFailedToLoad', modelNameWithoutExtension );
cloneDetectionExceptionLogObj = slEnginePir.util.CloneDetectionExceptionLog.getInstance;
cloneDetectionExceptionLogObj.addException( ExceptionLog );
continue ;
end 
end 
[ ~, blocksCount ] = sldiagnostics( modelNameWithoutExtension, 'CountBlocks' );
numberOfBlocksInCurrentModel = blocksCount( 1 ).count;
this.TotalNumberOfBlocks = this.TotalNumberOfBlocks + numberOfBlocksInCurrentModel;

curallmodels{ j } = modelNameWithoutExtension;
end 
allmodels = [ allmodels, curallmodels ];
end 
allmodels = allmodels( ~cellfun( @isempty, allmodels ) );

cd( curworkingdir );
end 

function creator = clonesAnywhere( ~, mdlList, clonepattern, domain, regionsize, clonegroupsize, ignoreSignalName, ignoreBlockProperty, includeLib )
creator = [  ];

try 
for i = length( mdlList ): - 1:1
mdlname = mdlList{ i };
isSubSystem = false;
slSubSysHandle = 0;
blockType = '';
if ( i == 1 )
mdlParent = get_param( mdlname, 'Parent' );
if ~isempty( mdlParent )
blockType = get_param( mdlname, 'BlockType' );
mdlname = bdroot( mdlParent );
end 
end 
if bdIsLoaded( mdlname )
slhandle = get_param( mdlname, 'Handle' );
if ( ~isempty( blockType ) && strcmp( blockType, 'SubSystem' ) )
isSubSystem = true;
slSubSysHandle = get_param( mdlList{ i }, 'Handle' );
end 
if ( i ~= 1 )
Simulink.SLPIR.CloneDetection.computeReferenceModelChecksum( slhandle, clonepattern, ignoreSignalName, ignoreBlockProperty );
end 
end 

if ( i == 1 )
cloneresultC = Simulink.SLPIR.CloneDetection.findClonesAnywhere( slhandle, clonepattern, false, regionsize, clonegroupsize, ignoreSignalName,  ...
ignoreBlockProperty, includeLib, isSubSystem, slSubSysHandle );
xformed_blks = struct( 'Region', {  }, 'After', {  } );
creator.differentBlockParamName = Simulink.SLPIR.CloneDetection.findDifferentBlockParams(  );
diffbp = creator.differentBlockParamName;
k = 1;
diffbp_tmp = struct( 'Block', {  }, 'ParameterNames', {  }, 'MappedBlocks', {  }, 'RefactorOption', {  } );
for j = 1:length( diffbp )
if ~isempty( diffbp( j ).ParameterNames )
diffbp_tmp( k ) = diffbp( j );
k = k + 1;
end 
end 
diffbp = diffbp_tmp;
for j = 1:length( diffbp )
len = length( diffbp( j ).MappedBlocks );
mappedfname = cell( len, 1 );
for k = 1:len
fname = getfullname( diffbp( j ).MappedBlocks( k ) );
mappedfname{ k } = fname;
end 
diffbp( j ).MappedBlocks = mappedfname;
end 
creator.differentBlockParamName = diffbp;

for j = 1:length( cloneresultC )
xformed_blks( j ).Region = cloneresultC( j ).CloneResults;
end 
creator.clonegroups = xformed_blks;
end 
end 
catch ME
disp( [ 'Exception in Clone Detection : ID - ', ME.identifier ] )
rethrow( ME )
end 
end 

function creator = computeChecksumAndGroupClones( this, mdlList, clonepattern, domain )
creator = [  ];
if ( nargin < 3 )
clonepattern = 'StructuralParameters';
domain = 'GraphicalDomain';
end 

if ( nargin < 4 )
domain = 'GraphicalDomain';
end 

for modelIndex = length( mdlList ): - 1:1
mdlname = mdlList{ modelIndex };
slSubSysHandle = 0;
isSubSystem = false;
if ( modelIndex == 1 )
mdlParent = get_param( mdlname, 'Parent' );
if ~isempty( mdlParent )
slSubSysHandle = get_param( mdlname, 'Handle' );
mdlname = bdroot( mdlParent );
end 
end 
if bdIsLoaded( mdlname )
slhandle = get_param( mdlname, 'Handle' );
Simulink.SLPIR.CloneDetection.computeSystemChecksum( slhandle, domain, clonepattern, this.ignoreSignalName, this.ignoreBlockProperty, slSubSysHandle, isSubSystem );
end 

if ( modelIndex == 1 )
cloneresultC = Simulink.SLPIR.CloneDetection.findClones(  );

xformed_blks = struct( 'Before', {  }, 'After', {  } );
for j = 1:length( cloneresultC )
xformed_blks( j ).Before = cloneresultC( j ).candidates;
end 
creator.clonegroups = xformed_blks;

if strcmp( clonepattern, 'StructuralParameters' ) == 0
creator.differentBlockParamName = Simulink.SLPIR.CloneDetection.findDifferentBlockParams(  );


diffbp = creator.differentBlockParamName;
for j = 1:length( diffbp )
len = length( diffbp( j ).MappedBlocks );
mappedfname = cell( len, 1 );
for k = 1:len
fname = getfullname( diffbp( j ).MappedBlocks( k ) );
mappedfname{ k } = fname;
end 
diffbp( j ).MappedBlocks = mappedfname;



objdp = get_param( diffbp( j ).Block, 'DialogParameters' );
tparmeternames = diffbp( j ).ParameterNames;
ind = 0;
for k = 1:length( diffbp( j ).ParameterNames )

if isSkippedParam( this, objdp, diffbp( j ).ParameterNames{ k } )
tparmeternames( k - ind ) = '';
ind = ind + 1;
end 
end 
if ~isempty( tparmeternames )
diffbp( j ).ParameterNames = tparmeternames;
end 
end 
creator.differentBlockParamName = diffbp;
end 
end 
end 
end 

function flag = isSkippedParam( ~, objdp, parametername )
flag = false;
if ~isfield( objdp, parametername )
flag = true;
return ;
end 



cond1 = ~isempty( nonzeros( strcmp( 'read-only', objdp.( parametername ).Attributes ) ) );
cond2 = ~isempty( nonzeros( strcmp( 'write-only', objdp.( parametername ).Attributes ) ) );
cond3 = ~isempty( nonzeros( strcmp( 'never-save', objdp.( parametername ).Attributes ) ) );
if cond1 || cond2 || cond3
flag = true;
end 
end 

function result = identify_clones( this, filterBuiltInLib, exclusionList, threshold )
if nargin < 2
filterBuiltInLib = false;
exclusionList = [  ];
threshold = 50;
end 

if nargin < 3
exclusionList = [  ];
threshold = 50;
end 
if nargin < 4
threshold = 50;
end 

addToExclusionList( this, exclusionList );

if isempty( this.creator )
return 
end 
if ~this.enableClonesAnywhere
this.checkChartInOutports(  );
end 

tmp = this.creator.clonegroups;
if length( tmp ) < 1
result = [  ];
return ;
end 

j = 1;
result = [  ];
if this.enableClonesAnywhere
result = struct( 'Region', {  } );
for i = 1:length( tmp )
for j = 1:length( tmp( i ).Region )
t = getfullname( tmp( i ).Region( j ).Candidates );
t = filterOutExclusionList( this, this.exclusionList, t );


if ( this.isReplaceExactCloneWithSubsysRef && ~this.isValidCloneGrpForSSRef( t ) )
continue ;
end 
result( i ).Region( j ).Candidates = t;
end 
end 
else 
for i = 1:length( tmp )
clonesInGroup = unique( getfullname( tmp( i ).Before ) );
clonesInGroup = filterOutExclusionList( this, this.exclusionList, clonesInGroup );
if length( clonesInGroup ) > 1
result{ j } = clonesInGroup;
sort( result{ j } );
j = j + 1;
end 
end 
end 

if isempty( result )
return ;
end 

if this.enableClonesAnywhere
for i = 1:length( result )
if length( result( i ).Region ) > 0
reg = sortRegion( this, result( i ).Region );
result( i ).Region = reg;
end 
end 
tmp = sortAndPruneCloneRegions( this, result );
this.cloneresult.Before = tmp;
tmp = groupCloneResultsExactSimilarForClonesAny( this, threshold, tmp );
result = tmp;
else 
result = sortAndPruneResult( this, result );

this.cloneresult.Before = result;
mask = false( size( result ) );

tmp = [  ];
ind = 1;
for i = 1:length( result )

for j = 1:length( result{ i } )
fname = result{ i }{ j };
if ~strcmp( get_param( fname, 'Type' ), 'block_diagram' ) &&  ...
( strcmp( get_param( fname, 'LinkStatus' ), 'resolved' ) || strcmp( get_param( fname, 'LinkStatus' ), 'implicit' ) ) &&  ...
isempty( get_param( fname, 'linkdata' ) )
if ~this.includeLib
result{ i }{ j } = '';
this.cloneresult.Before{ i }{ j } = '';
else 
result{ i }{ j } = get_param( fname, 'ReferenceBlock' );



for k = 1:j - 1
if strcmp( result{ i }{ k }, result{ i }{ j } )
result{ i }{ j } = '';
this.cloneresult.Before{ i }{ j } = '';
end 
end 
end 
end 
end 
result{ i }( strcmp( '', result{ i } ) ) = [  ];
this.cloneresult.Before{ i }( strcmp( '', this.cloneresult.Before{ i } ) ) = [  ];




filtered = filterOutShippedLibraries( this, filterBuiltInLib, result{ i }, false );
if length( result{ i } ) > 1 && ~filtered
tmp{ ind } = result{ i };%#ok
ind = ind + 1;
else 
mask( i ) = 1;
end 
end 

this.cloneresult.Before( mask ) = [  ];

tmp = groupCloneResultsExactSimilar( this, threshold, tmp );
result = tmp;
end 
end 


function reg = sortRegion( ~, region )
for regionIndex = 1:length( region )
for remainingRegionIndex = regionIndex + 1:length( region )
if ( length( region( regionIndex ).Candidates( 1 ) ) < length( region( remainingRegionIndex ).Candidates( 1 ) ) )
min = length( region( regionIndex ).Candidates( 1 ) );
elseif ( length( region( regionIndex ).Candidates( 1 ) ) > length( region( remainingRegionIndex ).Candidates( 1 ) ) )
min = length( region( remainingRegionIndex ).Candidates( 1 ) );
else 
min = length( region( remainingRegionIndex ).Candidates( 1 ) );
end 
reg1 = region( regionIndex ).Candidates{ 1 };
reg2 = region( remainingRegionIndex ).Candidates{ 1 };
for k = 1:min
if ( reg1( k ) > reg2( k ) )
a = region( regionIndex );
region( regionIndex ) = region( remainingRegionIndex );
region( remainingRegionIndex ) = a;
break ;
end 
end 
end 
end 
reg = region;
end 


function result = sortAndPruneCloneRegions( this, result )
len = length( result );
if len < 1
return ;
end 

for i = 1:len
for j = i + 1:len
if ( isLarger( this, result( i ).Region( 1 ).Candidates, result( j ).Region( 1 ).Candidates ) )
t = result( j );
result( j ) = result( i );
result( i ) = t;
end 
end 
end 

for i = 1:len
for j = i + 1:len
for k = 1:length( result( i ).Region )

for l = 1:length( result( j ).Region )
if ( ~isempty( result( i ).Region( k ).Candidates ) && ~isempty( result( j ).Region( l ).Candidates ) &&  ...
issubRegion( this, result( i ).Region( k ).Candidates, result( j ).Region( l ).Candidates ) )
if ( length( result( i ).Region ) < length( result( j ).Region ) ||  ...
length( result( i ).Region( k ).Candidates ) <= length( result( j ).Region( l ).Candidates ) )
result( i ).Region( k ).Candidates = {  };
else 
result( j ).Region( l ).Candidates = {  };
end 
end 
end 
end 
end 
end 

k = 1;
for i = 1:len

l = 1;
flag = 0;
reg = struct( 'Candidates', {  } );
for j = 1:length( result( i ).Region )
if ~isempty( result( i ).Region( j ).Candidates )
reg( l ) = result( i ).Region( j );
l = l + 1;
flag = 1;
end 
end 
if ( flag == 1 ) && length( reg ) > 1
tmp( k ).Region = reg;
k = k + 1;
end 
end 
result = tmp;
end 


function tmp = groupCloneResultsExactSimilarForClonesAny( this, threshold, tmp )

result = this.cloneresult.Before;
this.cloneresult.dissimiliarty = cell( 1, length( result ) );
this.cloneresult.dissimiliartyParamNum = zeros( 1, length( result ) );
mask = zeros( 1, length( result ) );

this.cloneresult.differentblocks = cell( size( result ) );

for i = 1:length( result )
clonegroup = result( i );
differentBlocks = cell( size( clonegroup.Region ) );
ind = [  ];
for j = 1:length( clonegroup.Region )
ind_reg = [  ];
for k = 1:length( clonegroup.Region( j ).Candidates )
blockcandName = clonegroup.Region( j ).Candidates{ k };
indtmp = [  ];
diffbp = this.creator.differentBlockParamName;

for l = 1:length( diffbp )
flag = false;
if slEnginePir.isParent( blockcandName, diffbp( l ).Block ) || strcmp( blockcandName, diffbp( l ).Block )
indtmp = [ indtmp, l ];
continue ;
end 
for m = 1:length( diffbp( l ).MappedBlocks )
fname = diffbp( l ).MappedBlocks{ m };
if slEnginePir.isParent( blockcandName, fname ) || strcmp( blockcandName, fname )
flag = true;
break ;
end 
end 
if flag
indtmp = [ indtmp, l ];
end 
end 
ind_reg = [ ind_reg, indtmp ];
end 
differentBlocks{ j } = ind_reg;
ind = [ ind, ind_reg ];
end 
ind = unique( ind );


paramNum = 0;
for j = 1:length( ind )
paramNum = paramNum + length( this.creator.differentBlockParamName( ind( j ) ).ParameterNames );
end 
this.cloneresult.dissimiliarty{ i } = ind;
this.cloneresult.dissimiliartyParamNum( i ) = paramNum;
this.cloneresult.differentblocks{ i } = differentBlocks;
if paramNum > threshold
mask( i ) = 1;
end 
end 


this.cloneresult.Before( mask == 1 ) = [  ];
this.cloneresult.dissimiliarty( mask == 1 ) = [  ];
this.cloneresult.dissimiliartyParamNum( mask == 1 ) = [  ];
this.cloneresult.differentblocks( mask == 1 ) = [  ];
tmp( mask == 1 ) = [  ];


[ newIndx, numblk ] = sortwithNumBlksNumClonesForClonesAnywhere( this, tmp );
this.cloneresult.NumberBlks = numblk;
newIndx = sortwithDissimiliartyParamNum( this, newIndx, this.cloneresult.dissimiliartyParamNum );
this.cloneresult.newIndx = newIndx;
end 

function [ tableIndx, numblk ] = sortwithNumBlksNumClonesForClonesAnywhere( ~, cloneResult )

result_size = length( cloneResult );
tableIndx = zeros( 1, result_size );
numblk = zeros( 1, result_size );

for i = 1:result_size
numblk( i ) = length( cloneResult( i ).Region( 1 ).Candidates );
tableIndx( i ) = length( cloneResult( i ) ) * numblk( i );
end 
[ ~, tableIndx ] = sort( tableIndx, 'ascend' );
end 


function clonesInGroup = filterOutExclusionList( ~, exclusionList, clonesInGroup )

if isempty( exclusionList )
return ;
end 
mask = zeros( 1, length( clonesInGroup ) );

for cloneIndex = 1:length( clonesInGroup )
for excludedCloneIndex = 1:length( exclusionList )
excludeSys = exclusionList{ excludedCloneIndex };
if slEnginePir.isParent( clonesInGroup{ cloneIndex }, getfullname( excludeSys ) ) ||  ...
slEnginePir.isParent( getfullname( excludeSys ), clonesInGroup{ cloneIndex } ) ||  ...
strcmp( clonesInGroup{ cloneIndex }, getfullname( excludeSys ) )


mask( cloneIndex ) = 1;
break ;
end 
end 
end 
clonesInGroup( mask == 1 ) = [  ];
end 



function addToExclusionList( this, excludesys )

for i = 1:length( excludesys )
fname = excludesys{ i };
if ~strcmp( get_param( fname, 'Type' ), 'block_diagram' ) && strcmp( get_param( fname, 'BlockType' ), 'ModelReference' )
modelNameToExclude = get_param( fname, 'ModelName' );
if ~strcmp( modelNameToExclude, '<Enter Model Name>' )
excludesys{ i } = modelNameToExclude;
end 
end 
end 


for i = 1:length( excludesys )
fname = excludesys{ i };
if strcmp( get_param( fname, 'Type' ), 'block_diagram' )
[ ~, referencedModels, ~, ~, explicitlyLoadedModels ] =  ...
slEnginePir.all_referlinked_blk( fname, [  ], {  }, 'on' );
this.loadedModels = [ this.loadedModels;explicitlyLoadedModels ];
this.exclusionList = unique( [ this.exclusionList, referencedModels ] );
end 
end 

this.exclusionList = unique( [ this.exclusionList, excludesys ] );
end 

function excludedBlocks = getExclusions( ~, modelName )
exclusionsObj = CloneDetector.Exclusions( get_param( modelName, 'name' ) );
excludedBlocks = exclusionsObj.getExcludedBlocks(  );
end 


function checkChartInOutports( this )
if isempty( this.creator )
return 
end 
oldclonegroups = this.creator.clonegroups;
if length( oldclonegroups ) < 1
return ;
end 

newclonegroups = this.creator.clonegroups;
newcgind = 1;
for i = 1:length( oldclonegroups )
tbefore = unique( oldclonegroups( i ).Before );
if length( tbefore ) > 1

len = length( tbefore );

dataProps = cell( len, 1 );

hasSF = false;
for j = 1:length( tbefore )
slhandle = tbefore( j );
if ~strcmp( get_param( slhandle, 'Type' ), 'block_diagram' ) && ~strcmpi( get_param( slhandle, 'SFBlockType' ), 'NONE' )

hasSF = true;
chartId = sfprivate( 'block2chart', slhandle );
dataIds = sf( 'DataIn', chartId );

dataIdsProps = [  ];
for k = 1:length( dataIds )
dataIdsProps = [ dataIdsProps, sf( 'get', dataIds( k ), '.props' ),  - 1 ];
end 

dataProps{ j } = dataIdsProps;
end 
end 

if ~hasSF
newclonegroups( newcgind ) = oldclonegroups( i );
newcgind = newcgind + 1;
continue ;
end 


for j = 1:len
for k = j + 1:len
if this.isLargerVec( dataProps{ j }, dataProps{ k } )
tdataprops = dataProps{ j };
dataProps{ j } = dataProps{ k };
dataProps{ k } = tdataprops;


tt = tbefore( j );
tbefore( j ) = tbefore( k );
tbefore( k ) = tt;
end 
end 
end 



newtbeforegroup = cell( len, 1 );
ind = 1;
newtbefore = tbefore( 1 );
pre = dataProps{ 1 };
for j = 2:len
if isequal( pre, dataProps{ j } )
newtbefore = [ newtbefore, tbefore( j ) ];
else 

pre = dataProps{ j };
if length( newtbefore ) > 1
newtbeforegroup{ ind } = newtbefore;
ind = ind + 1;
end 
newtbefore = tbefore( j );
end 
end 


if length( newtbefore ) > 1
newtbeforegroup{ ind } = newtbefore;
ind = ind + 1;
end 

if ind == 2 && length( newtbeforegroup{ 1 } ) == len
newclonegroups( newcgind ) = oldclonegroups( i );
newcgind = newcgind + 1;
continue ;
end 

if ind == 1
continue ;
end 


for j = 1:ind - 1
newclonegroups( newcgind ) = oldclonegroups( i );
newclonegroups( newcgind ).Before = newtbeforegroup{ j };
newcgind = newcgind + 1;
end 
end 
end 
this.creator.clonegroups = newclonegroups( 1:newcgind - 1 );
end 



function flag = isLargerVec( ~, v1, v2 )
flag = false;

if length( v1 ) > length( v2 )
flag = true;
return ;
elseif length( v1 ) < length( v2 )
return ;
end 


for i = 1:length( v1 )
if v1( i ) > v2( i )
flag = true;
return ;
end 
end 
end 

function result = sortAndPruneResult( this, result )
len = length( result );
if len < 1
return ;
end 

for i = 1:len
for j = i + 1:len
if ( isLarger( this, result{ i }, result{ j } ) )
t = result{ j };
result{ j } = result{ i };
result{ i } = t;
end 
end 
end 

pre = result{ 1 };
for i = 2:len
if issub( this, pre, result{ i } )
result{ i } = {  };
else 
pre = result{ i };
end 
end 

j = 1;
for i = 1:len
if ~isempty( result{ i } )
tmp{ j } = result{ i };%#ok
j = j + 1;
end 
end 
result = tmp;

end 

function flag = issub( ~, r1, r2 )
len1 = length( r1 );
len2 = length( r2 );
flag = true;
if len1 ~= len2
flag = false;
return ;
end 

for i = 1:len1
if ~strncmp( r1{ i }, r2{ i }, length( r1{ i } ) )
flag = false;
return ;
end 
end 
end 

function flag = issubRegion( ~, r1, r2 )
len1 = length( r1 );
len2 = length( r2 );
flag = true;
count = 0;

for i = 1:len1
for j = 1:len2
if strcmp( r1{ i }, r2{ j } )
count = count + 1;
break ;
end 
end 
end 
if ( count ~= 0 )
flag = true;
return ;
end 
flag = false;
end 

function flag = isLarger( this, ri, rj )
leni = length( ri );
lenj = length( rj );
flag = false;
if leni > lenj
flag = true;
return ;
elseif leni < lenj
flag = false;
return ;
end 
if intStrcmp( this, ri{ 1 }, rj{ 1 } ) > 0
flag = true;
end 
end 

function flag = intStrcmp( ~, s1, s2 )
len1 = length( s1 );
len2 = length( s2 );
len = min( len1, len2 );
for i = 1:len
if s1( i ) > s2( i )
flag = 1;
return ;
elseif s1( i ) < s2( i )
flag =  - 1;
return ;
end 
end 
if len1 > len
flag = 1;
return ;
elseif len2 > len
flag =  - 1;
return ;
end 
flag = 0;
end 


function filtered = filterOutShippedLibraries( ~, filterBuiltInLib, blocks, filtered )
if ~filterBuiltInLib
return ;
end 

flag = true;
for k = 1:length( blocks )
bdname = strtok( blocks{ k }, '/' );
[ ~, inside_mlroot ] = Simulink.loadsave.resolveFile( bdname );

if ~inside_mlroot
flag = false;
break ;
end 
end 
if flag
filtered = true;
end 
end 


function tmp = groupCloneResultsExactSimilar( this, threshold, tmp )

result = this.cloneresult.Before;
this.cloneresult.dissimiliarty = cell( 1, length( result ) );
this.cloneresult.dissimiliartyParamNum = zeros( 1, length( result ) );
mask = zeros( 1, length( result ) );

this.cloneresult.differentblocks = cell( size( result ) );

if strcmp( this.clonepattern, 'StructuralParameters' )

[ newIndx, numblk ] = sortwithNumBlksNumClones( this, tmp );
this.cloneresult.NumberBlks = numblk;
this.cloneresult.newIndx = newIndx;

return ;
end 
for i = 1:length( result )
clonegroup = result{ i };
[ ind, differentBlocks ] = isSimilarClones( this, clonegroup );

paramNum = 0;
for j = 1:length( ind )
paramNum = paramNum + length( this.creator.differentBlockParamName( ind( j ) ).ParameterNames );
end 
this.cloneresult.dissimiliarty{ i } = ind;
this.cloneresult.dissimiliartyParamNum( i ) = paramNum;
this.cloneresult.differentblocks{ i } = differentBlocks;
if paramNum > threshold
mask( i ) = 1;
end 
end 


this.cloneresult.Before( mask == 1 ) = [  ];
this.cloneresult.dissimiliarty( mask == 1 ) = [  ];
this.cloneresult.dissimiliartyParamNum( mask == 1 ) = [  ];
this.cloneresult.differentblocks( mask == 1 ) = [  ];
tmp( mask == 1 ) = [  ];


[ newIndx, numblk ] = sortwithNumBlksNumClones( this, tmp );
this.cloneresult.NumberBlks = numblk;
newIndx = sortwithDissimiliartyParamNum( this, newIndx, this.cloneresult.dissimiliartyParamNum );
this.cloneresult.newIndx = newIndx;
end 

function [ ind, differentBlocks ] = isSimilarClones( this, clonegroup )
differentBlocks = cell( size( clonegroup ) );
ind = [  ];
for i = 1:length( clonegroup )
blockcandName = clonegroup{ i };
indtmp = hasdifferparameter( this, blockcandName );
ind = [ ind, indtmp ];
differentBlocks{ i } = indtmp;
end 
ind = unique( ind );
end 

function ind = hasdifferparameter( this, blockcandName )

diffbp = this.creator.differentBlockParamName;
ind = [  ];

for j = 1:length( diffbp )
flag = false;
blockname = diffbp( j ).Block;
if slEnginePir.isParent( blockcandName, blockname )
flag = true;
ind = [ ind, j ];
end 
if flag
continue ;
end 

for k = 1:length( diffbp( j ).MappedBlocks )
fname = diffbp( j ).MappedBlocks{ k };
if slEnginePir.isParent( blockcandName, fname )
flag = true;
break ;
end 
end 
if flag
ind = [ ind, j ];
end 
end 
end 


function [ tableIndx, numblk ] = sortwithNumBlksNumClones( ~, tmp )

len = length( tmp );
tableIndx = zeros( 1, len );
numblk = zeros( 1, len );
for i = 1:len

bdname = strtok( tmp{ i }{ 1 }, '/' );
if ~bdIsLoaded( bdname )
load_system( bdname );
end 


if ~strcmp( get_param( tmp{ i }{ 1 }, 'Type' ), 'block_diagram' ) && ~strcmp( get_param( tmp{ i }{ 1 }, 'SFBlockType' ), 'NONE' )
numblk( i ) = 1;
else 
allblks = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on' );
allblksIn = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Inport' );
allblksOut = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Outport' );
numblk( i ) = length( allblks ) - 1 - length( allblksIn ) - length( allblksOut );
end 
tableIndx( i ) = length( tmp{ i } ) * numblk( i );
end 

[ ~, tableIndx ] = sort( tableIndx, 'descend' );
end 




function tableIndx = sortwithDissimiliartyParamNum( ~, tableIndx, dissimiliarty )

len = length( tableIndx );

for i = 1:len
for j = i + 1:len
ind1 = tableIndx( i );
len1 = dissimiliarty( ind1 );
ind2 = tableIndx( j );
len2 = dissimiliarty( ind2 );
if len1 > len2
t = tableIndx( i );
tableIndx( i ) = tableIndx( j );
tableIndx( j ) = t;
end 
end 
end 
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpG0fxDy.p.
% Please follow local copyright laws when handling this file.

