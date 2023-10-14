function templatePath = createReportTemplate( path, type )

arguments
    path( 1, 1 )string
    type( 1, 1 )string{ matlab.system.mustBeMember( type, [ "", "pdf", "html", "html-file", "docx" ] ) } = "";
end

[ templatePath, templateName, templateExt ] = fileparts( path );

if type == ""

    switch lower( templateExt )
        case { ".pdftx", ".pdf" }
            type = "pdf";
        case { ".dotx", ".docx" }
            type = "docx";
        case { ".htmtx", "htmx" }
            type = "html";
        case { ".htmt", "html" }
            type = "html-file";
        otherwise
            type = "pdf";
    end

end

basePath = mlreportgen.rpt2api.getDefaultReportTemplate( type );
[ ~, ~, templateExt ] = fileparts( basePath );
if templateExt == ""
    templatePath = path + templateExt;
else
    templatePath = fullfile( templatePath, templateName + templateExt );
end
copyfile( basePath, templatePath );
fileattrib( templatePath, "+w" );


