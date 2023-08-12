classdef InternalReqDocument < slreportgen.webview.DocumentBase








properties 
InitialBlock;
HomeSystem;
Systems;
SystemView;
OptionalViews;
IncludeNotes logical = false;
end 

methods 
function this = InternalReqDocument( outputFileName, packageType )
R36
outputFileName string
packageType string
end 
this@slreportgen.webview.DocumentBase( outputFileName );

this.PackageType = packageType;


this.TemplatePath = fullfile( slreportgen.webview.TemplatesDir, 'slwebview.htmtx' );

this.WebViewLibraryPath = fullfile( matlabroot, "toolbox/slreportgen/webview/resources/lib/slreqwebview" );
end 

function fillslwebview( h )
modelElement = slreportgen.webview.ModelReqElement( h,  ...
'slwebview',  ...
'100%',  ...
'100%',  ...
'support/slwebview.json' );

append( h, createDomElement( modelElement ) );


modelExporter = slreportgen.webview.ModelExporter( modelElement );


if ~isempty( h.SystemView )
modelExporter.SystemView = h.SystemView;
end 


modelExporter.OptionalViews = h.OptionalViews;


addChild( h.ProgressMonitor, modelExporter.ProgressMonitor );


export( modelExporter, h.Systems, h.HomeSystem, h.InitialBlock );
end 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpIsY7fG.p.
% Please follow local copyright laws when handling this file.

