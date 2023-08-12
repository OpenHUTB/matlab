function [ oStruct, parMdlRefs, isInSecond, hasEstimation ] = parComputeWeights( oStruct, parMdlRefs, targetType, buildTimeIsSaved )





if buildTimeIsSaved





tmp = num2cell( [ oStruct( : ).buildTime ] );
[ oStruct( : ).weight ] = tmp{ : };

isInSecond = true;
hasEstimation = false;
else 

[ oStruct( : ).buildTime ] = deal( 0 );
[ oStruct( : ).weight ] = deal( 0 );

isInSecond = true;
hasEstimation = false;
nodeWithAccurateTime = true( 1, length( oStruct ) );
mdlRefFileSizes = zeros( 1, length( oStruct ) );

for i = 1:length( oStruct )
iMdl = oStruct( i ).modelName;
try 
bs = coder.internal.infoMATFileMgr( 'getBuildStats', 'binfo', iMdl, targetType );
oStruct( i ).buildTime = bs.buildTime;
oStruct( i ).weight = bs.buildTime;
catch 

nodeWithAccurateTime( i ) = false;
isInSecond = false;
hasEstimation = true;

name = which( iMdl );
s = dir( name );
mdlRefFileSizes( i ) = s.bytes;
end 
end 
coder.internal.infoMATFileMgr( 'ClearRtwMatInfoFileStructs' );
end 

if ~isInSecond
if ~any( nodeWithAccurateTime )

tmpCell = num2cell( mdlRefFileSizes );
[ oStruct( : ).buildTime ] = deal( tmpCell{ : } );
[ oStruct( : ).weight ] = deal( tmpCell{ : } );
else 




oStructWithAccurateTime = oStruct( nodeWithAccurateTime );
[ maxBTime, maxIdx ] = max( [ oStructWithAccurateTime( : ).buildTime ] );
maxMdl = oStructWithAccurateTime( maxIdx ).modelName;
name = which( maxMdl );
s = dir( name );
maxFileSize = s.bytes;

fileSizeToTimeFactor = maxBTime / maxFileSize;

mdlRefBTimes = [ oStruct( : ).buildTime ];
mdlRefBTimes( ~nodeWithAccurateTime ) = mdlRefFileSizes( ~nodeWithAccurateTime ) * fileSizeToTimeFactor;

mdlRefBTimes = num2cell( mdlRefBTimes );
[ oStruct( : ).buildTime ] = deal( mdlRefBTimes{ : } );
[ oStruct( : ).weight ] = deal( mdlRefBTimes{ : } );

isInSecond = true;
end 
end 



allMdlRefNames = { oStruct( : ).modelName };
for i = length( oStruct ): - 1:1
pWeight = oStruct( i ).weight;
[ tf, idx ] = ismember( oStruct( i ).children, allMdlRefNames );
idx = idx( tf );
for nChild = 1:length( idx )
cBuildTime = oStruct( idx( nChild ) ).buildTime;
cWeight = oStruct( idx( nChild ) ).weight;
if ( cWeight < pWeight + cBuildTime )
oStruct( idx( nChild ) ).weight = pWeight + cBuildTime;
end 
end 
end 



allNodeNames = { oStruct( : ).modelName };
for lvl = 1:length( parMdlRefs )
[ ~, idx ] = ismember( { parMdlRefs{ lvl }( : ).modelName }, allNodeNames );
[ parMdlRefs{ lvl }( : ).buildTime ] = oStruct( idx ).buildTime;
[ parMdlRefs{ lvl }( : ).weight ] = oStruct( idx ).weight;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmplxRnMP.p.
% Please follow local copyright laws when handling this file.

