function location = getReportName( location, reportType, layoutID )




R36
location( 1, 1 )string
reportType( 1, 1 )string
layoutID( 1, 1 )string
end 

if isfolder( location )
filepath = location;
name = "";
ext = "";
else 
[ filepath, name, ext ] = fileparts( location );
end 

if ext == ""
switch reportType
case "pdf"
ext = ".pdf";
case "html-file"
ext = ".html";
otherwise 
assert( false, "Unsupported report type" );
end 
end 

if name == "" || name == "untitled"


project = currentProject;

if layoutID == ""



name = appID + "_" + project.Name;
else 
name = layoutID + "_" + project.Name;
end 
end 

location = fullfile( filepath, name + ext );
idx = 1;
while exist( location, "file" )
location = fullfile( filepath, name + num2str( idx ) + ext );
idx = idx + 1;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4ANM_E.p.
% Please follow local copyright laws when handling this file.

