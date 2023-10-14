function openProjectCreationDialog( options )

arguments
    options.Folder( 1, 1 )string{ mustBeNonzeroLengthText };
end

if matlab.internal.project.util.useWebFrontEnd

elseif usejava( 'jvm' )
    i_openJavaProjectCreationDialog( options );
end
end

function i_openJavaProjectCreationDialog( options )
parent = [  ];
controller = com.mathworks.toolbox.slproject.project.GUI.canvas.SingletonProjectCanvasController.getInstance;

if isfield( options, "Folder" )
    folder = java.io.File( options.Folder );
else
    folder = [  ];
end

com.mathworks.toolbox.slproject.project.GUI.creation.ProjectCreationDialog.showAsync( parent, controller, folder );
end


