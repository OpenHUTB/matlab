




classdef CloneDetection < handle
properties ( Access = 'public' )
creator;
mdl;
mdlName;
sysFullName;
refBlocksModels;
refModels;
libmdls;
linkedblks;
cloneresult;
m2m_dir;
excluded_sysclone;
genmodelprefix;
traceability_map;
includeLib;
clonepattern;
libraryblockcolor;
exclusionList;
cloneGrpsOfExclusionList;
considerDialogParameters;
considerSignalName;
considerCallbacks;
libname;
inputLibName;
changedLibraries;
isReplaceExactCloneWithSubsysRef;
diffParam;
loadedModels;
enableClonesAnywhere;
end 

properties ( SetAccess = 'public', GetAccess = 'public', Hidden = true )
region2BlockList;
end 

methods ( Access = 'public' )
function this = CloneDetection( mdl, enableClonesAnywhere, includeCommentedMdl, includeMdl, includeLib )
if nargin < 2
includeCommentedMdl = 'off';
end 
if nargin < 3
includeMdl = true;
end 
if nargin < 4
includeLib = true;
end 

this.mdl = mdl;
this.exclusionList = [  ];
C = textscan( mdl, '%s', 'Delimiter', '/' );
modelName = C{ 1 }{ 1 };
if ~bdIsLoaded( modelName )
open_system( modelName );
end 

this.sysFullName = getfullname( mdl );
this.mdlName = bdroot( this.sysFullName );
this.libmdls = [  ];
this.enableClonesAnywhere = enableClonesAnywhere;
this.linkedblks = [  ];
this.libraryblockcolor = 'red';
this.considerDialogParameters = false;
this.considerSignalName = true;
this.considerCallbacks = true;

if includeMdl || includeLib
[ this.refBlocksModels, this.refModels, this.linkedblks, ~, explicitlyLoadedModels ] =  ...
slEnginePir.all_referlinked_blk( this.mdlName, [  ], {  }, includeCommentedMdl );
this.loadedModels = [ this.loadedModels;explicitlyLoadedModels ];
if ~isempty( this.linkedblks )
this.libmdls = unique( { this.linkedblks.lib } );
end 
end 
if ~includeMdl
this.refBlocksModels = [  ];
this.refModels = [  ];
end 

if ~includeLib
this.libmdls = [  ];
this.linkedblks = [  ];
end 
this.includeLib = includeLib;

this.excluded_sysclone = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
this.changedLibraries = containers.Map( 'KeyType', 'char', 'ValueType', 'logical' );
this.region2BlockList = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
this.isReplaceExactCloneWithSubsysRef = false;
this.traceability_map = [  ];

this.m2m_dir = [ 'm2m_', this.mdlName, '/' ];
end 


function creator = computeChecksumAndGroupClones( this, mdlList, clonepattern, domain, ignoreSignalName, ignoreBlockProperty )
R36
this
mdlList
clonepattern string = 'StructuralParameters'
domain string = ''
ignoreSignalName logical = true
ignoreBlockProperty logical = true
end 
creator = [  ];

try 
for i = length( mdlList ): - 1:1
mdlname = mdlList{ i };
isSubSystem = false;
slSubSysHandle = 0;
if ( i == 1 )
mdlParent = get_param( mdlname, 'Parent' );
if ~isempty( mdlParent )
blockType = get_param( mdlname, 'BlockType' );
if ( strcmp( blockType, 'SubSystem' ) )
isSubSystem = true;
slSubSysHandle = get_param( mdlname, 'Handle' );
end 
mdlname = bdroot( mdlParent );
end 
end 
if bdIsLoaded( mdlname )
slhandle = get_param( mdlname, 'Handle' );
Simulink.SLPIR.CloneDetection.computeSystemChecksum( slhandle, domain, clonepattern, ignoreSignalName, ignoreBlockProperty, slSubSysHandle, isSubSystem );
end 

if ( i == 1 )

cloneresultC = Simulink.SLPIR.CloneDetection.findClones(  );

xformed_blks = struct( 'Before', {  }, 'After', {  } );
for j = 1:length( cloneresultC )
xformed_blks( j ).Before = cloneresultC( j ).candidates;
end 
creator.clonegroups = xformed_blks;

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
this.diffParam = diffbp;
end 
end 
catch ME
disp( [ 'Exception in Clone Detection : ID - ', ME.identifier ] )
rethrow( ME )
end 
end 


function creator = clonesAnywhere( this, mdlList, clonepattern, domain, regionsize, clonegroupsize, ignoreSignalName, ignoreBlockProperty, includeLib )
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
creator.differentBlockParamName = Simulink.SLPIR.CloneDetection.findDifferentBlockParamsForClonesAnywhere(  );
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
this.diffParam = diffbp;

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

function t = filterOutOutofScope( this, t )

mask = ones( 1, length( t ) );



fullname = getfullname( this.sysFullName );
if strcmp( get_param( fullname, 'BlockType' ), 'ModelReference' )
fullname = get_param( fullname, 'ModelName' );
end 

for i = 1:length( t )
if slEnginePir.isParent( fullname, t{ i } ) ||  ...
strcmp( t{ i }, fullname )


mask( i ) = 0;
end 
end 
t( mask == 1 ) = [  ];
end 




function addToExclusionList( this, excludesys )


for i = 1:length( excludesys )
fname = excludesys{ i };
if ~strcmp( get_param( fname, 'Type' ), 'block_diagram' ) && strcmp( get_param( fname, 'BlockType' ), 'ModelReference' )
t = get_param( fname, 'ModelName' );
if ~strcmp( t, '<Enter Model Name>' )
excludesys{ i } = t;
end 
end 
end 


for i = 1:length( excludesys )
fname = excludesys{ i };
if strcmp( get_param( fname, 'Type' ), 'block_diagram' )
[ ~, referencedModels, ~ ] = slEnginePir.all_referlinked_blk( fname, [  ], {  }, 'on' );
this.exclusionList = unique( [ this.exclusionList, referencedModels ] );
end 
end 

this.exclusionList = unique( [ this.exclusionList, excludesys ] );
end 


function removeFromExclusionList( this, excludesys )

tmp = cell( 1, length( this.exclusionList ) );
ind = 1;

excludesys = unique( excludesys );

for i = 1:length( this.exclusionList )
flag = false;
for j = 1:length( excludesys )
if strcmp( this.exclusionList{ i }, excludesys{ j } )
flag = true;
break ;
end 
end 
if ~flag
tmp( ind ) = this.exclusionList( i );
ind = ind + 1;
end 
end 


for i = ind:length( this.exclusionList )
tmp( i ) = '';
end 

this.exclusionList = tmp;
end 


function removeFromExclusionListByIndex( this, ind )
this.exclusionList( ind ) = '';
end 


function result = identifyClones( this, exclusionList, threshold )

if nargin < 2
exclusionList = [  ];
end 

if nargin < 3
threshold = 50;
end 
modifiedExclusionList = {  };
for idx = 1:length( exclusionList )
if getSimulinkBlockHandle( exclusionList{ idx } ) ~=  - 1
modifiedExclusionList{ end  + 1 } = exclusionList{ idx };%#ok<AGROW>
end 
end 

addToExclusionList( this, modifiedExclusionList );
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
ind = 1;
if this.enableClonesAnywhere
result = struct( 'Region', {  } );
for i = 1:length( tmp )
for j = 1:length( tmp( i ).Region )
t = getfullname( tmp( i ).Region( j ).Candidates );
t = filterOutExclusionList( this, this.exclusionList, t );

if ~strcmp( this.mdlName, this.sysFullName )
t = filterOutOutofScope( this, t );
end 


if ( this.isReplaceExactCloneWithSubsysRef && ~this.isValidCloneGrpForSSRef( t ) )
continue ;
end 
result( i ).Region( j ).Candidates = t;
end 
end 
else 
for i = 1:length( tmp )
t = unique( getfullname( tmp( i ).Before ) );
t = filterOutExclusionList( this, this.exclusionList, t );
if length( t ) < 2
this.cloneGrpsOfExclusionList{ ind } = t;
ind = ind + 1;
end 

if ~strcmp( this.mdlName, this.sysFullName )
t = filterOutOutofScope( this, t );
end 


if ( this.isReplaceExactCloneWithSubsysRef && ~this.isValidCloneGrpForSSRef( t ) )
continue ;
end 

if length( t ) > 1
result{ j } = t;
sort( result{ j } );
j = j + 1;
end 
end 
end 
if isempty( result )
return ;
end 

if this.enableClonesAnywhere
result = sortAndPruneCloneRegions( this, result );
this.cloneresult.Before = result;
result = groupCloneResultsExactSimilarForClonesAny( this, threshold, result );
this.creator.clonegroups = result;
for i = 1:length( result )
for j = 1:length( result( i ).Region )
for k = 1:length( result( i ).Region( j ).Candidates )
fname = result( i ).Region( j ).Candidates{ k };
if ( strcmp( get_param( fname, 'LinkStatus' ), 'resolved' ) || strcmp( get_param( fname, 'LinkStatus' ), 'implicit' ) ) &&  ...
isempty( get_param( fname, 'linkdata' ) )
if ~this.includeLib
result( i ).Region( j ).Candidates{ k } = '';

else 
result( i ).Region( j ).Candidates{ k } = get_param( fname, 'ReferenceBlock' );
end 
end 
end 
end 
end 
for i = 1:length( result )
for j = 1:length( result( i ).Region )
if length( result( i ).Region( j ).Candidates ) > 1
result( i ).Region( j ).Candidates = sort( result( i ).Region( j ).Candidates );
end 
end 
end 
for i = 1:length( result )
if length( result( i ).Region ) > 0
reg = sortRegion( this, result( i ).Region );
result( i ).Region = reg;
end 
end 
if ( length( result ) > 1 )
reg = sortGroup( this, result );
result = reg;
end 
this.cloneresult.Before = result;
else 
result = sortAndPruneResult( this, result );

this.cloneresult.exact = [  ];
this.cloneresult.similar = [  ];
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




filtered = filterOutShippedLibraries( this, result{ i }, false ) ...
 || filterOutSystemNotHierarchical( this, result{ i }, false );

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

getChangedLibraries( this, result );
end 
end 


function flag = regionsIntersect( ~, ele1, ele2 )
len1 = length( ele1 );
len2 = length( ele2 );
flag = false;
for i = 1:len1
for j = 1:len2
if ( strcmp( ele1{ i }, ele2{ j } ) )
flag = true;
break ;
end 
end 
end 
end 

function reg = unionRegion( ~, ele1, ele2 )
len1 = length( ele1 );
len2 = length( ele2 );
reg = [  ];
l = 1;
for l = 1:len1
reg{ l } = ele1{ l };
end 

for i = 1:len2
count = 0;
for j = 1:len1
if ~strcmp( ele2{ i }, ele1{ j } )
count = count + 1;
end 
end 
if ( count == j )
reg{ l + 1 } = ele2{ i };
l = l + 1;
end 
end 
end 


function getChangedLibraries( this, result )



reflen = length( this.refBlocksModels );
for m = 1:reflen
blockname = this.refBlocksModels( m ).block;
C = textscan( blockname, '%s', 'Delimiter', '/' );
modelName = C{ 1 }{ 1 };
if bdIsLoaded( modelName ) && strcmp( get_param( modelName, 'BlockDiagramType' ), 'library' )
this.changedLibraries( modelName ) = true;
end 
end 

if strcmp( this.clonepattern, 'StructuralParameters' )
return ;
end 

for i = 1:length( result )
if isempty( this.cloneresult.dissimiliarty{ i } )
continue ;
end 



clonegroup = result{ i };
for j = 1:length( clonegroup )
blockcandName = clonegroup{ j };
C = textscan( blockcandName, '%s', 'Delimiter', '/' );
modelName = C{ 1 }{ 1 };
if bdIsLoaded( modelName ) && strcmp( get_param( modelName, 'BlockDiagramType' ), 'library' )
this.changedLibraries( modelName ) = true;
end 
end 
end 
end 



function filtered = filterOutShippedLibraries( ~, blocks, filtered )

flag = true;
for k = 1:length( blocks )
bdname = strtok( blocks{ k }, '/' );

inside_mlroot = 0;
if bdIsLoaded( bdname ) && strcmp( get_param( bdname, 'BlockDiagramType' ), 'library' )
inside_mlroot = Advisor.component.isMWFile( sls_resolvename( bdname ) );
elseif ~bdIsLoaded( bdname )
inside_mlroot = 1;
end 
if ~inside_mlroot
flag = false;
break ;
end 
end 
if flag
filtered = true;
end 
end 





function filtered = filterOutSystemNotHierarchical( ~, blocks, filtered )

for k = 1:length( blocks )
oCP = get_param( blocks{ k }, 'Object' );

status = any( strcmp( class( oCP ),  ...
Advisor.component.internal.Object2ComponentID.ComponentObjectClasses ) );

if status && isa( oCP, 'Simulink.SubSystem' )





status = oCP.isHierarchical &&  ...
~any( strcmp( { 'System Requirements', 'System Requirement Item', 'DocBlock' }, oCP.MaskType ) );

if ~status
filtered = true;
return ;
end 
end 
end 
end 


function tmp = groupCloneResultsExactSimilarForClonesAny( this, threshold, tmp )

result = tmp;
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


function tmp = groupCloneResultsExactSimilar( this, threshold, tmp )

result = this.cloneresult.Before;
this.cloneresult.dissimiliarty = cell( 1, length( result ) );
this.cloneresult.dissimiliartyParamNum = zeros( 1, length( result ) );
mask = zeros( 1, length( result ) );

this.cloneresult.differentblocks = cell( size( result ) );

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


function reg = sortRegion( ~, region )
for i = 1:length( region )
for j = i + 1:length( region )
reg1 = string( region( i ).Candidates{ 1 } );
reg2 = string( region( j ).Candidates{ 1 } );
if reg1 > reg2
a = region( i );
region( i ) = region( j );
region( j ) = a;
break ;
end 
end 
end 
reg = region;
end 

function reg = sortGroup( ~, res )
for i = 1:length( res )
for j = i + 1:length( res )
if ( length( res( i ).Region( 1 ).Candidates ) == length( res( j ).Region( 1 ).Candidates ) )
reg1 = string( res( i ).Region( 1 ).Candidates{ 1 } );
reg2 = string( res( j ).Region( 1 ).Candidates{ 1 } );
if reg1 > reg2
a = res( i );
res( i ) = res( j );
res( j ) = a;
end 
end 
end 
end 
reg = res;
end 


function [ tableIndx, numblk ] = sortwithNumBlksNumClones( this, tmp )

len = length( tmp );
tableIndx = zeros( 1, len );
numblk = zeros( 1, len );
for i = 1:len

bdname = strtok( tmp{ i }{ 1 }, '/' );
if ~bdIsLoaded( bdname )
load_system( bdname );
this.loadedModels = [ this.loadedModels;bdname ];
end 

if ~strcmp( get_param( tmp{ i }{ 1 }, 'Type' ), 'block_diagram' ) &&  ...
~this.enableClonesAnywhere &&  ...
~strcmp( get_param( tmp{ i }{ 1 }, 'SFBlockType' ), 'NONE' )
numblk( i ) = 1;
else 
if Simulink.internal.useFindSystemVariantsMatchFilter( 'DEFAULT_ALLVARIANTS' )
allblks = find_system( tmp{ i }{ 1 }, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on' );
allblksIn = find_system( tmp{ i }{ 1 }, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Inport' );
allblksOut = find_system( tmp{ i }{ 1 }, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Outport' );
else 
allblks = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on' );
allblksIn = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Inport' );
allblksOut = find_system( tmp{ i }{ 1 }, 'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'blocktype', 'Outport' );
end 

numblk( i ) = length( allblks ) - 1 - length( allblksIn ) - length( allblksOut );
end 
tableIndx( i ) = length( tmp{ i } ) * numblk( i );
end 

[ ~, tableIndx ] = sort( tableIndx, 'descend' );
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

function [ ind, differentBlocks ] = isSimilarClones( this, clonegroup )
differentBlocks = cell( size( clonegroup ) );
ind = [  ];
for i = 1:length( clonegroup )
blockcandName = clonegroup{ i };
indtmp = slEnginePir.CloneRefactor.hasdifferparameter( this, blockcandName );
ind = [ ind, indtmp ];
differentBlocks{ i } = indtmp;
end 
ind = unique( ind );
end 


function undoModelRefactor( this, backmdlprefix )


mdls = [ { this.mdl }, this.refModels ];
if exist( this.m2m_dir, 'dir' ) == 0
DAStudio.error( 'sl_pir_cpp:creator:BackupFolderNotFound', this.m2m_dir );
end 
slEnginePir.undoModelRefactor( mdls, backmdlprefix, this.m2m_dir );

slEnginePir.undoModelRefactor( this.changedLibraries.keys,  ...
backmdlprefix, this.m2m_dir );
close_system( this.libname, 0 );
end 


function setConsiderDialogParameters( this, flag )
this.considerDialogParameters = flag;
end 

function flag = getConsiderDialogParameters( this )
flag = this.considerDialogParameters;
end 

function setConsiderSignalName( this, flag )
this.considerSignalName = flag;
end 

function flag = getConsiderSignalName( this )
flag = this.considerSignalName;
end 


function setConsiderCallbacks( this, flag )
this.considerCallbacks = flag;
end 

function flag = getConsiderCallbacks( this )
flag = this.considerCallbacks;
end 

function result = isValidCloneGrpForSSRef( ~, cloneGroupCandidates )
count_of_ssref = 0;
for i = 1:length( cloneGroupCandidates )
if strcmp( get_param( cloneGroupCandidates{ i }, 'type' ), 'block_diagram' )
continue ;
end 

block_handle = getSimulinkBlockHandle( cloneGroupCandidates{ i } );
if ~SSRefUtil.passesSSRefChecksForConversion( block_handle )

if strcmp( get_param( block_handle, 'BlockType' ), 'SubSystem' ) &&  ...
~isempty( get_param( block_handle, 'ReferencedSubsystem' ) )

count_of_ssref = count_of_ssref + 1;
continue ;
end 
result = false;
return ;
end 

end 

result = ~( count_of_ssref == length( cloneGroupCandidates ) );
end 

function closeOpenedModels( this )
this.loadedModels = slEnginePir.util.closeBlockDiagramsInList( this.loadedModels );
end 
end 

methods ( Access = 'private' )


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

function checkChartInOutports( this )

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
tmp = struct( 'Region', {  } );
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
end 
end 








% Decoded using De-pcode utility v1.2 from file /tmp/tmpCDKXw8.p.
% Please follow local copyright laws when handling this file.

