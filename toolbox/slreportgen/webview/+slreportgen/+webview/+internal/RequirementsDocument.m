classdef RequirementsDocument < slreportgen.webview.DocumentBase

































properties 


Project slreportgen.webview.internal.Project



HomeDiagram slreportgen.webview.internal.Diagram




SystemView slreportgen.webview.ViewExporter


IncludeNotes logical = false;
end 

properties ( Constant, Access = private )
WebAppID string = "slwebview";
TargetPackagePath string = "support/slwebview.json";
SupportPackagePath string = "support/slwebview_files";
end 

methods 
function this = RequirementsDocument( outputFileName, packageType )
R36
outputFileName string
packageType string
end 
this@slreportgen.webview.DocumentBase( outputFileName );
this.PackageType = packageType;

reqView = slreportgen.webview.views.RequirementsViewExporter(  );
reqView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
reqView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
reqView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );
reqView.FinderDataExporter = slreportgen.webview.FinderDataExporter(  );
reqView.HighlightBeforeExport = true;
reqView.IsGeneratingNewReport = true;

this.SystemView = reqView;
this.WebViewLibraryPath = fullfile( matlabroot, "toolbox/slreportgen/webview/resources/lib/slreqwebview" );
end 

function fillslwebview( this )
modelElement = slreportgen.webview.ModelReqElement( this,  ...
char( this.WebAppID ),  ...
'100%',  ...
'100%',  ...
char( this.TargetPackagePath ) );
this.append( modelElement.createDomElement(  ) );

director = slreportgen.webview.internal.ExportDirector(  );
director.Project = this.Project;
director.HomeDiagram = this.HomeDiagram;
director.SystemView = this.SystemView;
director.TargetPackagePath = this.TargetPackagePath;
director.SupportPackagePath = this.SupportPackagePath;
director.IncludeNotes = this.IncludeNotes;
director.Cache = false;
director.Indent = 1;


this.ProgressMonitor.setMaxValue( 0 );
this.ProgressMonitor.addChild( director.ProgressMonitor );

director.export( this );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgqGpXR.p.
% Please follow local copyright laws when handling this file.

