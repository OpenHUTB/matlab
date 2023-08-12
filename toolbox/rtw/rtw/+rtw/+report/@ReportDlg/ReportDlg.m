


classdef ReportDlg < handle




properties 
reportFolder = '';
mdlTarget = '';
sys = '';
end 

properties ( Access = private )
hModelCloseListener;
end 

methods ( Access = protected )

function reportInfo = loadRptInfo( obj, buildDir )
reportInfo = [  ];
if ~isempty( buildDir )

try 
reportInfo = rtw.report.ReportInfo.loadMat( obj.sys, buildDir );
if isa( reportInfo, 'rtw.report.ReportInfo' )
reportInfo.link( bdroot( obj.sys ) );
end 
catch ME
reportInfo = [  ];

errordlg( ME.message );
end 
end 
end 
end 

methods ( Access = public, Hidden = false )
function dlg = ReportDlg( sys )
dlg.sys = sys;




simPrefCfg = Simulink.fileGenControl( 'getConfig' );


stf = get_param( bdroot( dlg.sys ), 'SystemTargetFile' );
dlg.mdlTarget = strtok( strtok( stf, ' ' ), '.' );
dlg.reportFolder = simPrefCfg.CodeGenFolder;


dlg.installModelCloseListener(  );
end 

function delete( obj )
rtw.report.ReportDlg.rptDlg( obj.sys, 'close' );
end 

function installModelCloseListener( obj )



h = @( a, b, x )x.delete;
blkDiagram = get_param( bdroot( obj.sys ), 'Object' );
obj.hModelCloseListener = Simulink.listener( blkDiagram, 'CloseEvent',  ...
@( src, evt )h( src, evt, obj ) );

end 


function browseReportLocation( obj, h )
currentPath = h.getWidgetValue( 'openrpt_ReportFolder' );
if isempty( currentPath )
simPrefCfg = Simulink.fileGenControl( 'getConfig' );
currentPath = simPrefCfg.CacheFolder;
end 

pathName = uigetdir( currentPath, 'Find directory' );

if pathName ~= 0
obj.reportFolder = pathName;
h.setWidgetValue( 'openrpt_ReportFolder', pathName );
end 
end 


function generateReport( obj, rptInfo )
rptInfo.emitHTML(  );
rptInfo.show(  );
delete( obj );
end 




function helpReport( obj )%#ok<MANU>
try 
helpview( [ docroot, '/toolbox/rtw/helptargets.map' ], 'slcg_report_dlg' );
catch ME
errordlg( ME.message );
end 
end 


function cancelReport( obj )
delete( obj );
end 


function openReport( obj )
rptInfo = obj.loadRptInfo( obj.reportFolder );
if ~isempty( rptInfo )

try 

if ~exist( rptInfo.getReportDir, 'dir' ) ||  ...
~exist( rptInfo.getReportFileFullName, 'file' )
generateReport( obj, rptInfo );
else 
rptInfo.show;
delete( obj );
end 
catch ME

errordlg( ME.message );
end 
end 
end 

function out = getActionTag( ~ )
out = 'openReportButton';
end 
function out = getActionName( ~ )
out = DAStudio.message( 'RTW:report:btnOpen' );
end 
function out = getActionMethod( ~ )
out = 'openReport';
end 
function out = getTitle( obj )
out = DAStudio.message( 'RTW:report:titleOpenReport', obj.sys );
end 
function schema = getDialogSchema( obj )
tag_prefix = 'openrpt_';


lblDescription.Type = 'text';
lblDescription.Name = DAStudio.message( 'RTW:report:lblOpenReportDescription' );
lblDescription.RowSpan = [ 1, 1 ];
lblDescription.ColSpan = [ 1, 1 ];
lblDescription.Tag = [ tag_prefix, 'OpenReportDescription' ];
lblDescription.WordWrap = true;

grpReportDescription.Type = 'group';
grpReportDescription.Name = DAStudio.message( 'RTW:report:grpDescription' );
grpReportDescription.LayoutGrid = [ 1, 1 ];
items = { lblDescription };

grpReportDescription.Items = items;




editFolder.Type = 'edit';
editFolder.RowSpan = [ 1, 1 ];
editFolder.ColSpan = [ 2, 2 ];
editFolder.Mode = 1;
editFolder.DialogRefresh = 1;
editFolder.Source = obj;
editFolder.ObjectProperty = 'reportFolder';
editFolder.ListenToProperties = { 'reportFolder' };
editFolder.Tag = [ tag_prefix, 'ReportFolder' ];
editFolder.ToolTip = DAStudio.message( 'RTW:report:editFolderToolTip' );



editFolderLbl.Type = 'text';
editFolderLbl.Alignment = 2;
editFolderLbl.Name = DAStudio.message( 'RTW:report:lblCodeGenFolder' );
editFolderLbl.RowSpan = [ 1, 1 ];
editFolderLbl.ColSpan = [ 1, 1 ];
editFolderLbl.Tag = [ tag_prefix, 'ReportDirectoryLabel' ];
editFolderLbl.Buddy = editFolder.Tag;


btnBrowseReportLocationDir.Type = 'pushbutton';
btnBrowseReportLocationDir.Name = DAStudio.message( 'RTW:report:btnBrowse' );
btnBrowseReportLocationDir.RowSpan = [ 1, 1 ];
btnBrowseReportLocationDir.ColSpan = [ 3, 3 ];
btnBrowseReportLocationDir.Mode = 1;
btnBrowseReportLocationDir.DialogRefresh = 1;
btnBrowseReportLocationDir.Source = obj;
btnBrowseReportLocationDir.ObjectMethod = 'browseReportLocation';
btnBrowseReportLocationDir.MethodArgs = { '%dialog' };
btnBrowseReportLocationDir.ArgDataTypes = { 'handle' };
btnBrowseReportLocationDir.Tag = [ tag_prefix, 'BrowseOutputDirButton' ];
btnBrowseReportLocationDir.ToolTip = DAStudio.message( 'RTW:report:btnBrowseToolTip' );

grpReportFolder.Type = 'group';
grpReportFolder.Name = DAStudio.message( 'RTW:report:grpLocateDir' );
grpReportFolder.LayoutGrid = [ 1, 3 ];
items = { editFolderLbl, editFolder, btnBrowseReportLocationDir };

grpReportFolder.Items = items;






btnOpenReport.Type = 'pushbutton';
btnOpenReport.RowSpan = [ 1, 1 ];
btnOpenReport.ColSpan = [ 3, 3 ];
btnOpenReport.Tag = [ tag_prefix, obj.getActionTag ];
btnOpenReport.Name = obj.getActionName;
btnOpenReport.ObjectMethod = obj.getActionMethod;
btnOpenReport.Enabled = true;


btnHelpReport.Type = 'pushbutton';
btnHelpReport.Name = DAStudio.message( 'RTW:report:btnHelp' );
btnHelpReport.RowSpan = [ 1, 1 ];
btnHelpReport.ColSpan = [ 5, 5 ];
btnHelpReport.ObjectMethod = 'helpReport';
btnHelpReport.Tag = [ tag_prefix, 'helpReportButton' ];


btnCancelReport.Type = 'pushbutton';
btnCancelReport.Name = DAStudio.message( 'RTW:report:btnCancel' );
btnCancelReport.RowSpan = [ 1, 1 ];
btnCancelReport.ColSpan = [ 4, 4 ];
btnCancelReport.ObjectMethod = 'cancelReport';
btnCancelReport.Tag = [ tag_prefix, 'cancelReportButton' ];


pnlButton.Type = 'panel';
pnlButton.LayoutGrid = [ 1, 5 ];
pnlButton.ColStretch = [ 0, 0, 0, 0, 0 ];
pnlButton.Items = { btnOpenReport, btnHelpReport, btnCancelReport };

schema.DialogTitle = obj.getTitle;
schema.DialogTag = [ tag_prefix, 'dialog' ];

schema.CloseCallback = 'rtw.report.ReportDlg.CloseCallback';
schema.CloseArgs = { '%dialog' };

schema.OpenCallback = @rtw.report.ReportDlg.OpenCallback;

schema.StandaloneButtonSet = pnlButton;
schema.IsScrollable = false;
schema.Items = { grpReportDescription, grpReportFolder };
end 




function dataType = getPropDataType( ~, propName )
dataType = 'invalid';

if strcmp( propName, 'reportFolder' )
dataType = 'string';
end 

end 
end 

methods ( Static )


function CloseCallback( h )
dlgSrc = h.getSource;
rtw.report.ReportDlg.rptDlg( dlgSrc.sys, 'close' );
end 


function OpenCallback( h )
dlgSrc = h.getSource;
h.setWidgetValue( 'openrpt_ReportFolder', dlgSrc.reportFolder );
end 


openReportCallback( h )


function regenOptAction( reportInfo )
reportInfo.close(  );
reportInfo.update(  );
reportInfo.show(  );
end 


function openOptAction( reportInfo )
reportInfo.show(  );
end 


function out = rptDlg( sys, action )

persistent currentDlgMap;
if isempty( currentDlgMap )
currentDlgMap = containers.Map;
end 


sysObj = get_param( sys, 'Object' );
if strcmp( sysObj.Path, sysObj.Name )
sys = sysObj.Name;
else 
sys = [ sysObj.Path, '/', sysObj.Name ];
end 
rootName = bdroot( sys );


if strcmp( action, 'open' )



if ~currentDlgMap.isKey( rootName )
currentDlgMap( rootName ) = rtw.report.ReportDlg( sys );
out = currentDlgMap( rootName );
else 
out = [  ];
end 

elseif strcmp( action, 'close' )


if currentDlgMap.isKey( rootName )
currentDlgMap.remove( rootName );
out = [  ];
end 

else 


out = [  ];
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmplUS64E.p.
% Please follow local copyright laws when handling this file.

