function templatePath = getDefaultReportTemplate( rptType )













R36
rptType( 1, 1 )string{ matlab.system.mustBeMember( rptType, [ "pdf", "html", "html-file", "docx" ] ) }
end 

basePath = fullfile( matlabroot,  ...
"toolbox/shared/mlreportgen/base/resources/templates/rpt2api" );

switch lower( rptType )
case "pdf"
templatePath = fullfile( basePath, "pdf", "default.pdftx" );
case "docx"
templatePath = fullfile( basePath, "docx", "default.dotx" );
case "html"
templatePath = fullfile( basePath, "html", "default.htmtx" );
otherwise 
templatePath = fullfile( basePath, "html", "default.htmt" );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpIIvVGw.p.
% Please follow local copyright laws when handling this file.

