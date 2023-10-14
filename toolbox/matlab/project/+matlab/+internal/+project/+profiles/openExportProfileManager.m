function openExportProfileManager( project )

arguments
    project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
end

if matlab.internal.project.util.useWebFrontEnd
    matlab.internal.project.view.postCommand( project.RootFolder, "manageExportProfiles", [ string.empty ] );
elseif usejava( 'jvm' )
    matlab.internal.project.util.processJavaCall( @(  )i_openJavaExportProfileManager( project ) );
end
end

function i_openJavaExportProfileManager( project )
controlset = com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getMatchingControlSet( java.io.File( project.RootFolder ) );
projectui = javaMethodEDT( "findProjectUI", "com.mathworks.toolbox.slproject.project.GUI.projectui.ProjectUI", controlset );

factory = javaMethodEDT( "getInstance", "com.mathworks.toolbox.slproject.project.GUI.canvas.factory.ProjectCanvasFactorySingleton" );
javaMethodEDT( "show", factory );

extension = javaObjectEDT( "com.mathworks.toolbox.slproject.project.GUI.export.ExportProfileManagerExtension", projectui );
action = javaObjectEDT( "com.mathworks.toolbox.slproject.project.GUI.canvas.actions.ShareProjectAction", projectui, extension );
action.actionPerformed( [  ] );
end

