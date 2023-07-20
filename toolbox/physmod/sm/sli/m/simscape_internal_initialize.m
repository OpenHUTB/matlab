function simscape_internal_initialize





    if simmechanics.sli.internal.is_gui_possible()

        javaMethodEDT('initJNI',...
        'com.mathworks.physmod.sm.gui.app.editor.MechEditorDTClient');
    end


    mech2_register_java_dialogs;




end
