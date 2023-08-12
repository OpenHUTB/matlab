classdef SLService < handle






properties 
reqData slreq.data.ReqData
end 

methods 

function obj = SLService(  )
obj.reqData = slreq.data.ReqData.getInstance(  );
end 

function scratchReqSet = getScratchReqSet( obj )
reqSetName = 'slinternal_scratchpad.slreqx';
mfReqSet = obj.reqData.findRequirementSet( reqSetName );

if isempty( mfReqSet )
mfReqSet = obj.reqData.addRequirementSet( reqSetName );
mfReqSet.description = '';
scratchReqSet = obj.reqData.wrap( mfReqSet );
else 
scratchReqSet = obj.reqData.wrap( mfReqSet );
end 
end 

function clearClipboard( obj )
obj.reqData.clearClipboard(  );
end 

function moveReqToScratch( obj, slReqRow )
scratchReqSet = obj.getScratchReqSet(  );
obj.reqData.moveRequirement( slReqRow, 'on', scratchReqSet );
end 

function moveRequirement( obj, child, moveType, parent )
obj.reqData.moveRequirement( child, moveType, parent );
end 

function restoreReqFromScratch( obj, cutSID, origReqParent, origSID )
scratchReqSet = obj.getScratchReqSet(  );
cutSLReqRow = obj.findRowWithSID( scratchReqSet, cutSID );

obj.reqData.moveRequirement( cutSLReqRow, 'on', origReqParent );

obj.restoreSID( cutSLReqRow, origSID );
end 

function restoreSID( obj, cutSLReqRow, origSID )




mfReqRow = obj.reqData.getModelObj( cutSLReqRow );
mfReqRow.sid = origSID;
end 

function dataReqSet = loadOrCreateReqSetForModel( obj, mdlH )
if Simulink.harness.isHarnessBD( mdlH )

mdlName = Simulink.harness.internal.getHarnessOwnerBD( mdlH );
else 
mdlName = get_param( mdlH, 'Name' );
end 
dataReqSet = obj.getOrCreateReqSet( mdlH );
dataReqSet.parent = [ mdlName, '.slx' ];
end 

function closeReqSetForModel( obj, mdlH )
reqSetName = obj.reqData.getSfReqSet( mdlH );
if isempty( reqSetName )
return ;
end 
mfReqSet = obj.reqData.findRequirementSet( reqSetName );
if isempty( mfReqSet )
return ;
end 

dataReqSet = obj.reqData.wrap( mfReqSet );
obj.reqData.discardReqSet( dataReqSet );

obj.reqData.removeFromSfReqSetMap( mdlH );

mgr = slreq.app.MainManager.getInstance(  );
lastOprView = mgr.getLastOperatedView(  );
if isa( lastOprView, 'slreq.internal.gui.SfReqView' )
mgr.setLastOperatedView( [  ] );
end 
end 

function dataRow = findRowWithSID( ~, dataReqSet, sid )
dataRow = dataReqSet.getItemFromID( sid );
end 

function dataRow = addRowForBlock( obj, dataReqSet, blkH )


reqInfo.summary = get_param( blkH, 'Name' );




reqInfo.id = '';

reqInfo.description = getfullname( blkH );


groupUri = [ reqInfo.summary, '/', reqInfo.description ];
domain = 'Stateflow:ReqTable';

group = obj.reqData.getGroup( groupUri, domain, dataReqSet );

reqInfo.group = group;
reqInfo.domain = domain;
reqInfo.artifactUri = groupUri;

reqInfo.artifactId = get_param( blkH, 'SID' );
dataRow = obj.reqData.addExternalRequirement( dataReqSet, reqInfo );
end 

function thisReq = addRow( obj, dataReqParent, options )
R36
obj
dataReqParent
options.summary = ''
options.description = ''


options.id = ''




options.sid = ''
end 

reqInfo = struct( 'summary', options.summary,  ...
'description', options.description,  ...
'id', options.id );

thisReq = obj.reqData.addRequirement( dataReqParent, reqInfo );
end 

function dasRow = getDasWrapper( ~, dataRow )
dasRow = dataRow.getDasObject(  );
if isempty( dasRow )
dasParent = findNearestParentWithDasWrapper( dataRow );
initializeDasWrappers( dasParent );
end 
dasRow = dataRow.getDasObject(  );
end 

function setCurrentObject( ~, dasRow )
app = slreq.app.MainManager.getInstance;
app.setSelectedObject( dasRow );
end 

function copyOrCutRows( obj, dataRows, isCopy )
if isCopy
obj.reqData.copyReqToClipboard( dataRows );
else 
obj.reqData.cutReqToClipboard( dataRows );
end 
end 

function deleteRequirement( obj, dataRows )
for rowObj = dataRows
obj.reqData.removeRequirement( rowObj );
end 
end 

function pasteObjects( obj, destObj )
obj.reqData.pasteFromClipboard( destObj );
end 

function reqSet = reconcileEmbeddedReqsetName( obj, modelHandle )



preReqSetName = obj.reqData.getSfReqSet( modelHandle );

if isempty( preReqSetName )
reqSet = [  ];
return 
end 



nameTokens = split( preReqSetName, '_' );
sid = nameTokens{ end  };

reqSet = obj.reqData.getReqSet( preReqSetName );
assert( ~isempty( reqSet ) );


modelName = getfullname( modelHandle );
curReqSetName = [ modelName, '_', sid ];

if ~strcmp( curReqSetName, preReqSetName )
slReqSet = slreq.find( 'Type', 'ReqSet', 'Name', preReqSetName );
slReqSet.rename( curReqSetName );
reqSet.parent = [ modelName, '.slx' ];

obj.reqData.addToSfReqSetMap( modelHandle, curReqSetName );
end 
end 

function setDirty( ~, req )
req.setDirty( true );
end 
end 

methods ( Access = private )
function dataReqSet = getOrCreateReqSet( obj, mdlHandle )

loadedReqSetName = obj.reqData.getSfReqSet( mdlHandle );

if isempty( loadedReqSetName )
mdlName = get_param( mdlHandle, 'Name' );
sid = getNewSIDForModel( mdlHandle );
reqSetName = [ mdlName, '_', num2str( sid ) ];
mfReqSet = obj.reqData.addRequirementSet( reqSetName );
mfReqSet.description = '';
mfReqSet.modelSid = num2str( sid );
dataReqSet = obj.reqData.wrap( mfReqSet );

obj.reqData.addToSfReqSetMap( mdlHandle, reqSetName );
else 
mfReqSet = obj.reqData.findRequirementSet( loadedReqSetName );
dataReqSet = obj.reqData.wrap( mfReqSet );
end 

mgr = slreq.app.MainManager.getInstance;
mgr.init;




dasWrapper = dataReqSet.getDasObject(  );


if isempty( dasWrapper )
mgr.reqRoot.addSLReqSet( dataReqSet );
end 
end 
end 
end 


function dasWrapper = findNearestParentWithDasWrapper( row )
dasWrapper = [  ];
while true
dasWrapper = row.getDasObject(  );
if ~isempty( dasWrapper )
return ;
end 
if isempty( row.parent )
dataReqSet = row.getReqSet;
dasWrapper = dataReqSet.getDasObject(  );


assert( ~isempty( dasWrapper ) );
return ;
end 
row = row.parent;
end 
end 

function initializeDasWrappers( dasObj )
dasChildren = dasObj.getChildren(  );
for i = 1:length( dasChildren )
initializeDasWrappers( dasChildren( i ) );
end 
end 

function sid = getNewSIDForModel( mdl )
cursid = get_param( mdl, 'SIDHighWaterMark' );
assert( ~isempty( cursid ) );
sid = str2double( cursid ) + 1;
set_param( mdl, 'SIDNewHighWaterMark', num2str( sid ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpD5jB4C.p.
% Please follow local copyright laws when handling this file.

