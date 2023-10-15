function runExternalFixtures( uiDir )
arguments
    uiDir( 1, 1 )string = fullfile( matlabroot, "test", "toolbox", "stm", "contextmenu", "ui" );


end

if ispc
    drive = extractBefore( uiDir, filesep );
    system( "start cmd /K """ + drive + " & cd " + uiDir + ' & runExternalFixtures"' );
elseif ~ismac
    system( "gnome-terminal -e 'sh -c ""cd " + uiDir + "; mw runExternalFixtures""'" );
else
    system( "osascript -e 'tell app ""Terminal"" to do script ""cd " + uiDir + "; env TMP=$TMPDIR mw runExternalFixtures""'" );
end
end
