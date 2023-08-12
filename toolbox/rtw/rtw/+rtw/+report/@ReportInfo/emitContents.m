function emitContents( obj, filename )


bIsERTTarget = obj.IsERTTarget;
if nargin < 2
filename = obj.getContentsFileFullName;
end 

document = Advisor.Document;
document.addHeadItem( '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' );
document.addHeadItem( '<link rel="stylesheet" type="text/css" href="rtwreport.css" />' );
document.addHeadItem( locGetJavaScript );
if ~Simulink.report.ReportInfo.featureOpenInStudio
document.setBodyAttribute( 'bgcolor', '#eeeeee' );
end 
document.setBodyAttribute( 'link', '#0033cc' );
document.setBodyAttribute( 'vlink', '#666666' );
document.setBodyAttribute( 'rightmargin', '0' );

entries = {  };

entries{ end  + 1, 1 } = Advisor.Text( 'Contents', { 'bold' } );


if bIsERTTarget
msgLink = locCreateSectionLink( DAStudio.message( 'RTW:report:ModelToCodeMessageLink' ), 'rtwmsg.html', 'rtwIdMsgFileLink' );
msgLink.setAttribute( 'style', 'display: none' );
entries{ end  + 1, 1 } = msgLink;
end 


obj.getSortedFileInfoList;


obj.emitPages(  );

for k = 1:length( obj.Pages )
p = obj.Pages{ k };
entries{ end  + 1, 1 } = p.getDocumentLink;%#ok<AGROW>
end 

contents = Advisor.Table( length( entries ), 1 );
contents.setAttribute( 'class', 'toc' );

for k = 2:length( entries )
entries{ k }.setAttribute( 'target', 'rtwreport_document_frame' );
entries{ k }.setAttribute( 'onclick', 'if (top) if (top.tocHiliteMe) top.tocHiliteMe(window, this, true);' );
entries{ k }.setAttribute( 'name', 'TOC_List' );
end 
contents.setEntries( entries );

document.addItem( contents );

document.addItem( '<!--ADD_CODE_PROFILE_REPORT_LINK_HERE-->' );


if bIsERTTarget && ( ~rtw.report.ReportInfo.DisplayInCodeTrace || obj.hasWebview )
navButtons = Advisor.Table( 2, 1 );
navButtons.setAttribute( 'class', 'panel small_font' );
navButtons.setAttribute( 'style', 'display: none; margin-top: 10px; margin-bottom: 10px' );
navButtons.setAttribute( 'id', 'rtwIdTracePanel' );
navButtons.setEntry( 1, 1, Advisor.Text( DAStudio.message( 'RTW:report:HighlightNavigation' ), { 'bold' } ) );
navButtons.setEntry( 2, 1,  ...
[ '<INPUT TYPE="button" VALUE="' ...
, DAStudio.message( 'RTW:report:NavigationButtonPrevious' ) ...
, '" style="width: 85" ID="rtwIdButtonPrev" ONCLICK="if (top.rtwGoPrev) top.rtwGoPrev();" disabled="disabled" />' ...
, '<INPUT TYPE="button" VALUE="' ...
, DAStudio.message( 'RTW:report:NavigationButtonNext' ) ...
, '" style="width: 85" ID="rtwIdButtonNext" ONCLICK="if (top.rtwGoNext) top.rtwGoNext();" disabled="disabled" />' ] );
document.addItem( navButtons );
end 
if ~Simulink.report.ReportInfo.featureOpenInStudio
document.addItem( '<hr />' );
end 
document.addItem( obj.getGeneratedFilesPanel );
if ~isempty( obj.getGeneratedFilesPanel ) &&  ...
~Simulink.report.ReportInfo.featureOpenInStudio
document.addItem( '<hr />' );
end 

if ~isempty( obj.ModelReferences )
p = rtw.report.Submodels( obj.ModelReferencesReports,  ...
obj.ModelReferences );
document.addItem( p.emitHTML );
end 

fid = fopen( filename, 'w', 'n', 'utf-8' );
fwrite( fid, document.emitHTML, 'char' );
fclose( fid );

function out = locGetJavaScript
lines = { 
'<script language="JavaScript" type="text/javascript" defer="defer">'
'    function rtwFileListShrink(o, category, categoryMsg, numFiles)'
'    {'
'        var indent = document.getElementById(category + "_indent");'
'        var fileTable = document.getElementById(category + "_table");'
'        var catName = document.getElementById(category + "_name");'
'        if (fileTable.style.display == "none") {'
'            fileTable.style.display = "";'
'            indent.style.display = "";'
'            o.innerHTML = ''<span style="font-family:monospace" id = "'' + category + ''_button">[-]</span>'';'
'            catName.innerHTML = "<b>" + categoryMsg + "</b>";'
'        } else {'
'            fileTable.style.display = "none";'
'            indent.style.display = "none";'
'            o.innerHTML = ''<span style="font-family:monospace" id = "'' + category + ''_button">[+]</span>'';'
'            catName.innerHTML = "<b>" + categoryMsg + " (" + numFiles + ")" + "</b>";'
'        }'
'    }'
'</script>' };
out = sprintf( '%s\n', lines{ : } );

function out = locCreateSectionLink( text, href, id )

out = Advisor.Element;
out.setTag( 'a' );
out.setAttribute( 'href', href );
out.setAttribute( 'id', id );
out.setContent( text );





% Decoded using De-pcode utility v1.2 from file /tmp/tmpB0JnR_.p.
% Please follow local copyright laws when handling this file.

