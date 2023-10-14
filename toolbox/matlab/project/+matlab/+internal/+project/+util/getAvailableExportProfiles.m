function names = getAvailableExportProfiles( project )

arguments
    project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) }
end

if matlab.internal.project.util.useWebFrontEnd
    profiles = matlab.internal.project.profiles.getAvailableExportProfiles( project.RootFolder );
    names = unique( string( { profiles.Name } )' );
else
    names = i_getJavaExportProfiles( project );
end

end

function names = i_getJavaExportProfiles( project )
import matlab.internal.project.util.processJavaCall;
import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabProjectManager;
project = processJavaCall( @(  )MatlabAPIMatlabProjectManager.newInstance( char( project.RootFolder ), project.TopLevel ) );

names = project.getAvailableExportProfiles(  );
if isempty( names )
    names = string.empty( 0, 1 );
else
    names = sort( string( cellstr( names ) ) );
end
end


