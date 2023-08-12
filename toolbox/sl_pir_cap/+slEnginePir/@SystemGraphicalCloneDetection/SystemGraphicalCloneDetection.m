






classdef SystemGraphicalCloneDetection < slEnginePir.CloneDetection
methods ( Access = 'public' )



function this = SystemGraphicalCloneDetection( model, clonePattern, enableClonesAnywhere, includeModel, includeLib )
R36
model char
clonePattern string = 'StructuralParameters'
enableClonesAnywhere = false
includeModel logical = true
includeLib logical = true
end 

this@slEnginePir.CloneDetection( model, enableClonesAnywhere, 'on', includeModel, includeLib );

this.genmodelprefix = [ slEnginePir.util.Constants.BackupModelPrefix, '_' ];
this.clonepattern = clonePattern;
end 

function runCloneDetection( this, clonePattern, ignoreSignalName, ignoreBlockProperty )
R36
this
clonePattern string = 'StructuralParameters'
ignoreSignalName logical = true
ignoreBlockProperty logical = true
end 

this.creator = this.computeChecksumAndGroupClones( unique( [ { this.sysFullName }, this.refModels ], 'stable' ), clonePattern, 'GraphicalDomain', ignoreSignalName, ignoreBlockProperty );
end 

function runCloneAnywhere( this, clonePattern, regionSize, cloneGroupSize, ignoreSignalName, ignoreBlockProperty, includeLib )
this.creator = this.clonesAnywhere( unique( [ { this.sysFullName }, this.refModels ], 'stable' ), clonePattern, 'GraphicalDomain', regionSize, cloneGroupSize, ignoreSignalName, ignoreBlockProperty, includeLib );
end 

function result = identify_clones( this, exclusionList, threshold )
if nargin < 2
exclusionList = [  ];
end 

if nargin < 3
threshold = 50;
end 

result = this.identifyClones( exclusionList, threshold );
end 

function result = replace_clones( this, libname, genmodel_prefix, ignoreCSC )

mdls = { this.mdlName };
mdls = [ mdls, this.refModels, this.libmdls ];
explicitlyLoadedModels = slEnginePir.modelChanged( mdls );
this.loadedModels = [ this.loadedModels;explicitlyLoadedModels ];

this.excludeCommentedRegion(  );

if nargin <= 1
libname = 'graphicalCloneLibFile';
end 
if strcmp( this.clonepattern, 'StructuralParameters' )
this.libraryblockcolor = 'red';
else 
this.libraryblockcolor = 'cyan';
end 
if nargin > 3
[ result, explicitlyLoadedModels ] =  ...
slEnginePir.CloneRefactor.replaceClones( this, libname, genmodel_prefix, ignoreCSC );
elseif nargin > 2
[ result, explicitlyLoadedModels ] =  ...
slEnginePir.CloneRefactor.replaceClones( this, libname, genmodel_prefix );
else 
[ result, explicitlyLoadedModels ] =  ...
slEnginePir.CloneRefactor.replaceClones( this, libname );
end 

this.loadedModels = [ this.loadedModels;explicitlyLoadedModels ];
end 

function result = replace_clonesAnywhere( this, libraryname, genmodel_prefix )

mdls = { this.mdlName };
mdls = [ mdls, this.refModels, this.libmdls ];
slEnginePir.modelChanged( mdls );

if nargin <= 1
libname = 'graphicalCloneLibFile';
else 
libname = libraryname;
end 
if strcmp( this.clonepattern, 'StructuralParameters' )
this.libraryblockcolor = 'red';
else 
this.libraryblockcolor = 'cyan';
end 

result = slEnginePir.CloneRefactor.replaceClonesAnywhere( this, libname, genmodel_prefix );
end 
end 

methods ( Access = 'private' )

function excludeCommentedRegion( this )
if isempty( this.cloneresult )
return ;
end 
allCloneCandidates = this.cloneresult.Before;



findActiveSubsystem = @( candidate )find_system( candidate,  ...
'LookUnderMasks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on',  ...
'BlockType', 'SubSystem' );


findCommentedBlocksInActiveChoice = @( candidate )find_system( candidate,  ...
'LookUnderMasks', 'all',  ...
'FirstResultOnly', true,  ...
'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'IncludeCommented', 'on',  ...
'RegExp', 'on',  ...
'Commented', 'on|through' );

for i = 1:length( allCloneCandidates )
for j = 1:length( allCloneCandidates{ i } )
aCloneCandidate = allCloneCandidates{ i }{ j };
if strcmp( get_param( aCloneCandidate, 'Type' ), 'block_diagram' )
continue ;
end 
if strcmp( get_param( aCloneCandidate, 'Commented' ), 'through' )
this.excluded_sysclone( aCloneCandidate ) = 'Commented through subsystem.';
commented_subsys_inside = findActiveSubsystem( aCloneCandidate );
for k = 1:length( commented_subsys_inside )
this.excluded_sysclone( commented_subsys_inside{ k } ) = 'Commented through subsystem.';
end 
elseif strcmp( get_param( aCloneCandidate, 'Commented' ), 'on' )
this.excluded_sysclone( aCloneCandidate ) = 'Commented on subsystem.';
commented_subsys_inside = findActiveSubsystem( aCloneCandidate );
for k = 1:length( commented_subsys_inside )
this.excluded_sysclone( commented_subsys_inside{ k } ) = 'Commented on subsystem.';
end 
elseif ~isempty( findCommentedBlocksInActiveChoice( aCloneCandidate ) )
this.excluded_sysclone( aCloneCandidate ) = 'Includes Commented on/through blocks.';
end 
end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpmIDJcn.p.
% Please follow local copyright laws when handling this file.

