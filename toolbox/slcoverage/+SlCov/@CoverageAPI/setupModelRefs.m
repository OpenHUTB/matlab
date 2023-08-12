function setupModelRefs( accelMdlRefs, allMdlRefs )





try 
if ~slfeature( 'SlCovAccelCompileSupport' )
return ;
end 


isAnyRapidAcclerator = any( { accelMdlRefs.mdlRefSimMode } == "rapid-accelerator" );
coveng = [  ];
if ~isAnyRapidAcclerator
info = cvi.ModelInfoCache.getTopModelInfo(  );
topModelH = get_param( info.topModel, 'handle' );
if isempty( topModelH ) || ~SlCov.CoverageAPI.isCovAccelSimSupport( topModelH )


return ;
end 
coveng = cvi.TopModelCov.getInstance( topModelH );
end 
accelMdlRefs = checkMixedModes( coveng, accelMdlRefs, allMdlRefs );
for i = 1:length( accelMdlRefs )
modelName = accelMdlRefs( i ).modelName;
isProtected = accelMdlRefs( i ).protected;

isAcclerator = strcmpi( accelMdlRefs( i ).mdlRefSimMode, 'accelerator' );




SlCov.CoverageAPI.sfAutoscaleCache( modelName, 'forceOff' );

isEnabled = ~isProtected &&  ...
isAcclerator &&  ...
SlCov.CoverageAPI.isModelRefEnabledFromTop( modelName );



cvi.ModelInfoCache.cacheModelRef( modelName, isEnabled );


if isEnabled && ~isempty( coveng )
load_system( modelName );
coveng.addMdlRef( modelName, true );
set_param( modelName, 'RecordCoverageOverride', 'ForceOn' );
else 


if bdIsLoaded( modelName )
set_param( modelName, 'RecordCoverageOverride', 'ForceOff' );
end 
end 
end 
catch MEx
rethrow( MEx );
end 
end 

function accelMdlRefs = checkMixedModes( coveng, accelMdlRefs, allMdlRefs )

topMdlRefInfo = allMdlRefs( { allMdlRefs.pathToMdlRef } == "" );



accelMdlNames = { accelMdlRefs.modelName };
notSupportedAccelModels = {  };

[ ~, ~, iIdx ] = intersect( accelMdlNames, topMdlRefInfo.children );
if ~isempty( iIdx )

nIdx = find( contains( topMdlRefInfo.childSimMode( iIdx ), 'normal' ) );
if ~isempty( nIdx )
notSupportedAccelModels = topMdlRefInfo.children( nIdx );
end 
end 
if ~isempty( notSupportedAccelModels )
coveng.covModelRefData.notSupportedAccelModels = notSupportedAccelModels;
for idx = 1:numel( notSupportedAccelModels )
accelMdlRefs( { accelMdlRefs.modelName } == string( notSupportedAccelModels{ idx } ) ) = [  ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTgakHy.p.
% Please follow local copyright laws when handling this file.

