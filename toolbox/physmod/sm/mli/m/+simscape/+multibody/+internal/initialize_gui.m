function initialize_gui()




    if usejava('jvm')&&feature('ShowFigureWindows')

        javaMethodEDT('initJNI',...
        'com.mathworks.physmod.sm.gui.app.editor.MechEditorDTClient');
    end


    mech2_register_java_dialogs;

end

