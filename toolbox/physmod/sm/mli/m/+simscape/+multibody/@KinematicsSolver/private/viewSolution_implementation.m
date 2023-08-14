function viewSolution_implementation(ksObj)



    persistent initializedJavaDlg;

    if(isempty(initializedJavaDlg))
        initializedJavaDlg=true;
        mech2_register_java_dialogs();
    end

    ksObj.mSystem.viewSolution;
