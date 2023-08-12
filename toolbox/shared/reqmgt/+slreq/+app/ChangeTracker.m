classdef ChangeTracker < handle











properties ( Constant )


BACKGROUND_COLOR_WITH_CHANGE_ISSUE = [ 1, 0, 0, 0.2 ];
end 

properties 
ChangeAnalyzer
end 

methods ( Access = ?slreq.app.MainManager )

function this = ChangeTracker(  )
this.ChangeAnalyzer = slreq.analysis.ChangeTracker.getInstance(  );
end 



function delete( this )%#ok<INUSD>

end 
end 


methods 





function refreshReqSet( this, dasReqSets )
for index = 1:length( dasReqSets )
if isa( dasReqSets( index ), 'slreq.das.RequirementSet' )
dataReqSet = dasReqSets( index ).dataModelObj;
else 
dataReqSet = dasReqSets( index );
end 
this.ChangeAnalyzer.refreshReqSet( dataReqSet );
end 
end 


function refreshReq( this, dasReq )
for index = 1:length( dasReq )
dataReq = dasReq( index ).dataModelObj;
this.ChangeAnalyzer.refreshReq( dataReq );
end 
end 


function refreshReqToBeDeleted( this, dasReq )


dataReq = dasReq.dataModelObj;
this.ChangeAnalyzer.refreshReqToBeDeleted( dataReq );
end 


function refreshLink( this, dasLink )
dataLink = dasLink.dataModelObj;
this.ChangeAnalyzer.refreshLink( dataLink );
end 


function refreshLinkSet( this, dasLinkSet )
dataLinkSet = dasLinkSet.dataModelObj;
this.ChangeAnalyzer.refreshLinkSet( dataLinkSet );
end 


function refresh( this, allDasLinkSets )



R36
this
allDasLinkSets = slreq.das.LinkSet.empty(  )
end 

mgr = slreq.app.MainManager.getInstance(  );

if mgr.isAnalysisDeferred
if isempty( allDasLinkSets )
linkRoot = mgr.getLinkRoot;
if isempty( linkRoot )
allDasLinkSets = slreq.das.LinkSet.empty(  );
else 
allDasLinkSets = linkRoot.children;
end 
end 

if ~isempty( allDasLinkSets )
mgr.showDeferredAnalysisNotification(  );
end 
return ;
end 


if isempty( allDasLinkSets ) && mgr.isUserActionInProgress(  )
mgr.setUserActionFinishCallback( 'ChangeTracker.refresh', @(  )refresh( this ) );
return ;
end 

this.ChangeAnalyzer.reset(  );
if isempty( allDasLinkSets )
linkRoot = slreq.app.MainManager.getInstance.getLinkRoot;
if isempty( linkRoot )
allDasLinkSets = slreq.das.LinkSet.empty(  );
else 
allDasLinkSets = linkRoot.children;
end 
end 

for index = 1:length( allDasLinkSets )
cDasLinkSet = allDasLinkSets( index );
this.refreshLinkSet( cDasLinkSet );
end 
end 





function clearAllChangeIssues( this, dasLinkSet, commentInfo )
this.ChangeAnalyzer.clearAllChangeIssues( dasLinkSet.dataModelObj, commentInfo );
end 


function clearLinkedSourceIssue( this, dasLink, commentInfo )
this.ChangeAnalyzer.clearLinkedSourceIssues( dasLink.dataModelObj, commentInfo );
end 


function clearLinkedDestinationIssue( this, dasLink, commentInfo )
this.ChangeAnalyzer.clearLinkedDestinationIssues( dasLink.dataModelObj, commentInfo );
end 


function tf = hasLinksWithChangeIssue( this, reqUuid )

tf = this.ChangeAnalyzer.hasLinksWithChangeIssue( reqUuid );
end 


function tf = hasLinksWithSourceChangeIssue( this, reqUuid )

tf = this.ChangeAnalyzer.hasLinksWithSourceChangeIssue( reqUuid );
end 


function tf = hasInvalidLinks( this, reqUuid )
tf = this.ChangeAnalyzer.hasInvalidLinks( reqUuid );
end 
end 

methods ( Static )



function updateViews(  )










mgr = slreq.app.MainManager.getInstance;
ssmgr = mgr.spreadsheetManager;
ssmgr.update(  );


reqEditor = mgr.requirementsEditor;
if ~isempty( reqEditor ) && reqEditor.displayChangeInformation
reqEditor.update;
mgr.refreshUI(  );
end 
end 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMmHQDx.p.
% Please follow local copyright laws when handling this file.

