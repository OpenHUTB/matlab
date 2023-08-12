function replaceMdlRefBlks( obj )





obj.ErrorGroup = 2;



if ~obj.HasRepRulesForMdlRef
return ;
end 



obj.updateLibForModelRefCopy;


tempData.origAlgebraicLoopMsg = get_param( obj.MdlInfo.ModelH, 'AlgebraicLoopMsg' );
tempData.origArtificialAlgebraicLoopMsg = get_param( obj.MdlInfo.ModelH, 'ArtificialAlgebraicLoopMsg' );






set_param( obj.MdlInfo.ModelH, 'AlgebraicLoopMsg', 'warning' );
set_param( obj.MdlInfo.ModelH, 'ArtificialAlgebraicLoopMsg', 'warning' );
if strcmp( get_param( obj.MdlInfo.ModelH, 'UniqueDataStoreMsg' ), 'error' )




set_param( obj.MdlInfo.ModelH, 'UniqueDataStoreMsg', 'warning' );
end 

[ prevWarnMsg, prevWarnId ] = lastwarn;
lastwarn( '' );

try 
originalModelH = obj.MdlInfo.OrigModelH;
replacementModelH = obj.MdlInfo.ModelH;
Sldv.xform.BlkReplacer.createDDForReplacementMdl( originalModelH, replacementModelH, obj.MdlInfo.TestComp );


if ~obj.MdlInlinerOnlyMode


obj.MdlInfo.resetMdlBlkCacheInfo(  );
compInfoCacheListener = obj.MdlInfo.createInactiveMdlBlkPropCacheListener( obj.MdlInfo.ModelH );



obj.MdlInfo.compileModel( 'compile' );


delete( compInfoCacheListener );
end 











if ( 1 == slfeature( 'ObserverSLDV' ) )
obj.cacheObsPortEntityMappingInfo(  );
end 

obj.checkLastWarningForAlgebraicLoops;

obj.MdlInfo.constructMdlRefBlksTree( obj.MdlRefBlkRepRulesTree );

obj.checkLastWarningForAlgebraicLoops;

lastwarn( prevWarnMsg, prevWarnId );



obj.ErrorGroup = 3;

tempData.warningIds = Sldv.xform.BlkReplacer.listWarningsToTurnOffForMdlRef;
tempData.warningStatus = Sldv.xform.BlkReplacer.turnOffWarnings( tempData.warningIds );


obj.exeMdlRefRepRules;
catch Mex




obj.MdlInfo.termModel(  );

revertTemporaryChanges( obj, tempData );
rethrow( Mex );
end 

revertTemporaryChanges( obj, tempData );

if ~obj.MdlInlinerOnlyMode


obj.MdlInfo.compileModel( 'compile' );



obj.compareMdlRefReplacements;
end 
end 

function revertTemporaryChanges( obj, tempData )
if ~isempty( tempData )
if isfield( tempData, 'origAlgebraicLoopMsg' )
set_param( obj.MdlInfo.ModelH, 'AlgebraicLoopMsg', tempData.origAlgebraicLoopMsg );
end 

if isfield( tempData, 'origArtificialAlgebraicLoopMsg' )
set_param( obj.MdlInfo.ModelH, 'ArtificialAlgebraicLoopMsg', tempData.origArtificialAlgebraicLoopMsg );
end 

if isfield( tempData, 'warningIds' ) && isfield( tempData, 'warningStatus' )
Sldv.xform.BlkReplacer.restoreWarningStatus( tempData.warningIds, tempData.warningStatus );
end 
end 


obj.fixDiagnosticParameters;



obj.destroyLibForMdlRefCopy;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDQ7OYl.p.
% Please follow local copyright laws when handling this file.

