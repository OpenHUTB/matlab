function openStartupShutdownDialog( project )

arguments
    project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) }
end

if matlab.internal.project.util.useWebFrontEnd

    matlab.internal.project.view.openSettings( project.RootFolder, "Simulink" );
elseif usejava( 'jvm' )
    matlab.internal.project.util.processJavaCall( @(  )i_openJavaStartupShutdownDialog( project ) );
end
end

function i_openJavaStartupShutdownDialog( project )
controlset = com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getMatchingControlSet( java.io.File( project.RootFolder ) );
projectui = javaMethodEDT( "findProjectUI", "com.mathworks.toolbox.slproject.project.GUI.projectui.ProjectUI", controlset );

factory = javaMethodEDT( "getInstance", "com.mathworks.toolbox.slproject.project.GUI.canvas.factory.ProjectCanvasFactorySingleton" );
javaMethodEDT( "show", factory );

action = javaObjectEDT( "com.mathworks.toolbox.slproject.project.GUI.canvas.actions.StartupShutdownToolAction", projectui );
action.actionPerformed( [  ] );
end

