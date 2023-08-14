function model_editor_callback(modelH,cmd)



    import simmechanics.sli.internal.*


    if is_gui_possible()
        if(simmechanics.sli.internal.is_model_handle(modelH))
            mech2_editor_slcallback(modelH,cmd);
        end
    end
