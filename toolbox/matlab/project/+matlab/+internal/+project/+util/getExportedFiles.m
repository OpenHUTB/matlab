function files = getExportedFiles( project, profile )

arguments
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) }
profile( 1, 1 )string;
end 

if matlab.internal.project.util.useWebFrontEnd
profiles = matlab.internal.project.profiles.getAvailableExportProfiles( project.RootFolder );
idx = find( [ profiles.Name ] == profile );
if isempty( idx )
uuid = profile;
else 
uuid = profiles( idx( 1 ) ).UUID;
end 
files = matlab.internal.project.profiles.getExportedFiles( project.RootFolder, uuid );
else 
files = i_getJavaExportedFiles( project, profile );
end 

end 

function files = i_getJavaExportedFiles( project, profile )
import matlab.internal.project.util.processJavaCall;
import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabProjectManager;
project = processJavaCall( @(  )MatlabAPIMatlabProjectManager.newInstance( char( project.RootFolder ), project.TopLevel ) );

paths = project.getExportedFiles( profile );
if isempty( paths )
files = string.empty( 0, 1 );
else 
files = sort( string( cellstr( paths ) ) );
end 

end 
