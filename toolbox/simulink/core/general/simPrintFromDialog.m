function simPrintFromDialog( sys, scope, lookUnderMask, expandLibLinks, printInfo )























progressBar = [  ];

try 
GLUE2.Portal.cancelSpooling;

if ishandle( sys )
rootsys = bdroot( sys );
else 

obj = find( sfroot, 'Id', sys );
if isprop( obj, 'chart' )
obj = obj.chart;
end 
rootsys = bdroot( sfprivate( 'chart2block', obj.Id ) );
end 


if strcmp( printInfo.PrintTsLegend, 'on' ) && ~strcmpi( get_param( rootsys, 'SampleTimesAreReady' ), 'on' )
warndlg( getString( message( 'Simulink:SimPrintDlg:cannotPrintLegend' ) ),  ...
getString( message( 'Simulink:SimPrintDlg:printStatus' ) ) );
return ;
end 


if ~isempty( printInfo.FileName )
[ dir, ~, ext ] = fileparts( printInfo.FileName );
if ~isempty( dir ) && exist( dir, 'dir' ) == 0
warndlg( getString( message( 'glue2:portal:CannotSaveFile_InvalidParentDir',  ...
printInfo.FileName ) ) );
return ;
end 
if isempty( ext )

printInfo.FileName = [ printInfo.FileName, '.pdf' ];
end 
if ( exist( printInfo.FileName, 'file' ) == 2 )
lastwarn( '' );
delete( printInfo.FileName );
warn = lastwarn;
if ~isempty( warn )
warndlg( [ warn, ': ', printInfo.FileName ],  ...
getString( message( 'Simulink:SimPrintDlg:printStatus' ) ) );
return ;
end 
end 
end 

if ( ~GLUE2.Portal.setSpoolPrintOptions( printInfo ) )

return ;
end 


progressBar = waitbar(  ...
0, getString( message( 'Simulink:SimPrintDlg:findSystemsToPrint' ) ),  ...
'CloseRequestFcn', '',  ...
'Name', getString( message( 'Simulink:SimPrintDlg:printStatus' ) ) ...
 );


set( findall( progressBar, 'type', 'text' ), 'Interpreter', 'none' );


[ systems, resolved, unresolved ] = systems2print( sys, scope, lookUnderMask, expandLibLinks );
slObj = SLPrint.Utils.GetSLSFObject( sys );
r = find( systems == slObj, 1 );
if isempty( r )
warning( getString( message( 'Simulink:SimPrintDlg:notPrintingCurrentSystemWarning', slObj.Name ) ) );
end 

systemsToPrint = vertcat( systems, resolved );
numSys = length( systemsToPrint );


printFrame = SLPrint.PrintFrame.Instance(  );
if ~isempty( printInfo.PrintFrame )
printFrame.Init( printInfo.PrintFrame, numSys );
end 


pj = initPrintJob( printInfo );


GLUE2.Portal.beginSpooling;



numPages = numSys;
curPage = 0;
if strcmp( printInfo.PrintTsLegend, 'on' )
numPages = numPages + 1;
end 
if strcmp( printInfo.PrintLog, 'on' )
numPages = numPages + 1;
end 


for i = 1:numSys
curPage = curPage + 1;
msg = getString(  ...
message( 'Simulink:SimPrintDlg:printingPageStatus',  ...
num2str( i ), num2str( numPages ) ) );
waitbar( curPage / numPages, progressBar, msg );
pj.PageNumber = i;
obj = systemsToPrint( i );

if isa( obj, 'Simulink.SubSystem' ) && ~strcmpi( obj.SFBlockType, 'NONE' )
c = sfprivate( 'block2chart', obj.Handle );
obj = find( sfroot, 'Id', c );
end 


handled = handleStateflowState( obj );


if handled

if ~isempty( printInfo.PrintFrame )
printFrame.IncrementPageNum(  );
end 
else 
if isa( obj, 'Simulink.Object' )
pj.Handles = { obj.Handle };
else 
pj.Handles = { obj.Id };
end 
SLPrint.Printer.ExecutePrintJob( pj );
end 
end 


miscLogInfo = {  };


if strcmp( printInfo.PrintTsLegend, 'on' )
curPage = curPage + 1;
waitbar( curPage / numPages, progressBar,  ...
getString( message( 'Simulink:SimPrintDlg:printingLegendMsg' ) ) );
printSampleTimeLegends( rootsys );

miscLogInfo = cat( 1, miscLogInfo,  ...
getString( message( 'Simulink:SimPrintDlg:sampleTimeLegend' ) ) );
end 


if strcmp( printInfo.PrintLog, 'on' )
curPage = curPage + 1;
waitbar( curPage / numPages, progressBar,  ...
getString( message( 'Simulink:SimPrintDlg:printingLogFileMsg' ) ) );
printLog( systems, resolved, unresolved, miscLogInfo, printInfo );
end 


GLUE2.Portal.endSpooling;


printFrame.Reset(  );


delete( progressBar );

catch me

if ~isempty( progressBar )
delete( progressBar )
end 

printFrame = SLPrint.PrintFrame.Instance(  );
printFrame.Reset(  );

warning( me.getReport(  ) );
end 

end 

function pj = initPrintJob( printInfo )

pj = struct(  ...
'PaperOrientation', printInfo.PaperOrientation,  ...
'PaperType', printInfo.PaperType,  ...
'TiledPrint', 0,  ...
'FileName', '',  ...
'PrinterName', '',  ...
'FramePrint', '',  ...
'FromPage', 1,  ...
'ToPage', 9999,  ...
'Driver', 'psc',  ...
'DriverExt', '',  ...
'PageNumber', 0,  ...
'DPI',  - 1,  ...
'Verbose', 0 ...
 );

if isfield( printInfo, 'FileName' ) && ~isempty( printInfo.FileName )

pj.FileName = printInfo.FileName;
[ ~, ~, ext ] = fileparts( printInfo.FileName );
ext( 1 ) = [  ];
pj.Driver = ext;
pj.DriverExt = ext;
end 
if isfield( printInfo, 'PrinterName' ) && ~isempty( printInfo.PrinterName )
pj.PrinterName = printInfo.PrinterName;
end 
if isfield( printInfo, 'TiledPrint' ) && strcmp( printInfo.TiledPrint, 'on' )
pj.TiledPrint = 1;
end 
if isfield( printInfo, 'PrintFrame' ) && ~isempty( printInfo.PrintFrame )
pj.FramePrint = printInfo.PrintFrame;
end 
if isfield( printInfo, 'FromPage' )
pj.FromPage = printInfo.FromPage;
end 
if isfield( printInfo, 'ToPage' )
pj.ToPage = printInfo.ToPage;
end 

end 

function handled = handleStateflowState( obj )

handled = false;

if isa( obj, 'Stateflow.EMChart' )
script = obj.Script;

emlFile = tempname;
fid = fopen( emlFile, 'w' );
fprintf( fid, '%s', script );
fclose( fid );

SLPrint.PrintLog.Print( emlFile, '' );

delete( emlFile );
handled = true;
elseif isa( obj, 'Stateflow.TruthTableChart' ) || isa( obj, 'Stateflow.TruthTable' )
h = sfprivate( 'state_print_fig', obj.id, 1 );
tempFile = [ tempname, '.svg' ];
print( h, '-dsvg', '-painters', tempFile );







GLUE2.Portal.spoolPageFromFile( tempFile );

delete( tempFile );
handled = true;
elseif isa( obj, 'Stateflow.StateTransitionTableChart' )
htmlFile = Stateflow.STTUtils.STTUtilMan.export( obj, 'STT', 'html', '', true );
GLUE2.Portal.spoolPageFromFile( htmlFile );
handled = true;
elseif isa( obj, 'Stateflow.Chart' ) && Stateflow.ReqTable.internal.isRequirementsTable( obj.Id )
exporter = Stateflow.ReqTable.internal.ReqTableHTMLExporter( obj.Id );
html = exporter.getHTML;
tempFile = [ tempname, '.html' ];
fid = fopen( tempFile, 'wb', 'native', 'UTF-8' );
fwrite( fid, html );
fclose( fid );
GLUE2.Portal.spoolPageFromFile( tempFile );

delete( tempFile );
handled = true;
end 

end 

function printSampleTimeLegends( sys )

if strcmpi( get_param( sys, 'SampleTimesAreReady' ), 'on' )

obj = Simulink.SampleTimeLegend;

tempfile = [ tempname, '.html' ];
result = obj.getAsHTML( get_param( sys, 'Name' ), tempfile );
if result
GLUE2.Portal.spoolPageFromFile( tempfile );
delete( tempfile );
end 
end 

end 

function printLog( systems, resolved, unresolved, miscInfo, printInfo )



if isempty( printInfo.FileName )
printLogFileName = tempname;
else 
printLogFileName = [ printInfo.FileName, '.log' ];
end 

printLog = simprintlog( systems, resolved, unresolved );


fileID = fopen( printLogFileName, 'wt' );

for lp = 1:size( printLog, 1 )
fprintf( fileID, '%s\n', deblank( printLog( lp, : ) ) );
end 



if ( ~isempty( miscInfo ) )
fprintf( fileID, 'Other\n------\n' );
for i = 1:length( miscInfo )
fprintf( fileID, '%6d      %s\n', i, miscInfo{ i } );
end 
end 

fclose( fileID );

if ~isempty( printInfo.PrinterName )
SLPrint.PrintLog.Print( printLogFileName, '' );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpw983Mb.p.
% Please follow local copyright laws when handling this file.

