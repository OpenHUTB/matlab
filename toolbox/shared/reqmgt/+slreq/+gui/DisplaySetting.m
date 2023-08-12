classdef DisplaySetting < matlab.mixin.Copyable


 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
properties ( Access = public )
reqColumns = slreq.app.MainManager.DefaultRequirementColumns;
linkColumns = slreq.app.MainManager.DefaultLinkColumns;
reqSortInfo = struct( 'Col', '', 'Order', false );
linkSortInfo = struct( 'Col', '', 'Order', false );
reqColumnWidths = [  ];
linkColumnWidths = [  ];
displayChangeInformation = slreq.app.MainManager.DefaultDisplayChangeInformation;

spreadsheetWidth =  - 1;
spreadsheetHeight =  - 1;
spreadsheetDockPos = 'bottom';


reqActive = true;

viewName;
end 

properties ( SetAccess = ?slreq.gui.SpreadSheetData, Transient, NonCopyable )





dasReqRoot;
dasLinkRoot;

wasReset = false;
end 

methods 
function this = DisplaySetting( view )
this.viewName = view;
end 

function delete( this )

end 

function tf = isEditor( this )
tf = strcmp( this.viewName, slreq.gui.View.EDITOR );
end 

function tf = isequal( this, rhs )
tf = isequal( this.reqColumns, rhs.reqColumns ) ...
 && isequal( this.linkColumns, rhs.linkColumns ) ...
 && isequal( this.reqSortInfo, rhs.reqSortInfo ) ...
 && isequal( this.linkSortInfo, rhs.linkSortInfo ) ...
 && isequal( this.reqColumnWidths, rhs.reqColumnWidths ) ...
 && isequal( this.linkColumnWidths, rhs.linkColumnWidths ) ...
 && isequal( this.displayChangeInformation, rhs.displayChangeInformation ) ...
 && isequal( this.spreadsheetWidth, rhs.spreadsheetWidth ) ...
 && isequal( this.spreadsheetHeight, rhs.spreadsheetHeight ) ...
 && isequal( this.spreadsheetDockPos, rhs.spreadsheetDockPos ) ...
 && isequal( this.reqActive, rhs.reqActive ) ...
 && isequal( this.viewName, rhs.viewName );
end 

function takeSettings( this, other )
this.reqColumns = other.reqColumns;
this.linkColumns = other.linkColumns;
this.reqSortInfo = other.reqSortInfo;
this.linkSortInfo = other.linkSortInfo;
this.reqColumnWidths = other.reqColumnWidths;
this.linkColumnWidths = other.linkColumnWidths;
this.displayChangeInformation = other.displayChangeInformation;

this.spreadsheetWidth = other.spreadsheetWidth;
this.spreadsheetHeight = other.spreadsheetHeight;
this.spreadsheetDockPos = other.spreadsheetDockPos;


this.reqActive = other.reqActive;


this.viewName = other.viewName;
end 

function activate( this )
this.initDas(  );
if ~this.isEditor
data = this.getSpreadsheetDataObject(  );
if ~isempty( data )
data.updateDisplayedReqSet;
end 
end 
end 

function deActivate( this )
this.clear(  );


if ~this.isEditor
return ;
end 

if ~isempty( this.dasReqRoot )
this.dasReqRoot.delete;
this.dasReqRoot = [  ];
end 
if ~isempty( this.dasLinkRoot )
this.dasLinkRoot.delete;
this.dasLinkRoot = [  ];
end 
end 

function reset( this )
this.reqColumns = slreq.app.MainManager.DefaultRequirementColumns;
this.linkColumns = slreq.app.MainManager.DefaultLinkColumns;
this.reqSortInfo = struct( 'Col', '', 'Order', false );
this.linkSortInfo = struct( 'Col', '', 'Order', false );
this.reqColumnWidths = [  ];
this.linkColumnWidths = [  ];
this.displayChangeInformation = slreq.app.MainManager.DefaultDisplayChangeInformation;

this.spreadsheetWidth =  - 1;
this.spreadsheetHeight =  - 1;
this.spreadsheetDockPos = 'buttom';

this.reqActive = true;

this.wasReset = true;
end 

function das = getDasReqRoot( this, doInit )
R36
this
doInit = false;
end 
das = this.getDasRoot( true, doInit );
end 

function das = getDasLinkRoot( this, doInit )
R36
this
doInit = false;
end 
das = this.getDasRoot( false, doInit );
end 
end 

methods ( Access = protected )
function clear( this )



reqRoot = this.getDasReqRoot;
linkRoot = this.getDasLinkRoot;
if ~isempty( reqRoot ) && isvalid( reqRoot )
reqRoot.clearChildren( false );
 ...
 ...
 ...
 ...
 ...
 ...
end 
if ~isempty( linkRoot ) && isvalid( linkRoot )
linkRoot.clearChildren( false );
 ...
 ...
 ...
 ...
 ...
 ...
end 
end 

function dataObj = getSpreadsheetDataObject( this )
dataObj = [  ];

app = slreq.app.MainManager.getInstance;
dm = app.spreadSheetDataManager;
if isempty( dm )
return ;
end 
try 
h = get_param( this.viewName, 'handle' );
catch 
return ;
end 
if isempty( h )
return ;
else 
dataObj = dm.getSpreadSheetDataObject( h );
end 
end 

function r = getDasRoot( this, req, doInit )
if doInit
this.initDas(  );
end 
if this.isEditor
if req
r = this.dasReqRoot;
else 
r = this.dasLinkRoot;
end 
else 

r = this.getPerspectiveDasRoot( req );
end 
end 

function initDas( this, reInit )
R36
this
reInit = false;
end 
if ~isempty( this.dasReqRoot ) && isvalid( this.dasReqRoot ) && ~reInit
return ;
end 

if this.isEditor
this.dasReqRoot = slreq.das.ReqRoot( slreq.app.MainManager.getInstance );
this.dasLinkRoot = slreq.das.LinkRoot( slreq.app.MainManager.getInstance );
else 







this.dasReqRoot = slreq.das.BaseObject;
this.dasLinkRoot = slreq.das.BaseObject;
end 
end 

function root = getPerspectiveDasRoot( this, forReq )


root = [  ];
data = this.getSpreadsheetDataObject(  );
if ~isempty( data )
if forReq
root = data.reqRoot;
else 
root = data.linkRoot;
end 
end 
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYbVADZ.p.
% Please follow local copyright laws when handling this file.

