function isEnabled=getEnabledFlag(hSrc,objProp)
















    if~isSupportedWidget(hSrc,objProp)
        isEnabled=false;
        return
    end

    OptionsToBeDisabled={};




    profileGroup={'ProfileGenCode','profileBy','ProfileNumSamples'};


    switch(hSrc.buildFormat)
    case 'Makefile'
        OptionsToBeDisabled=[OptionsToBeDisabled,profileGroup];
    end


    switch(hSrc.buildAction)
    case 'Create_Processor_In_the_Loop_project'


        OptionsToBeDisabled=[OptionsToBeDisabled,{'exportIDEObj'}];
    end


    switch(hSrc.ProfileGenCode)
    case 'on'


        OptionsToBeDisabled=[OptionsToBeDisabled,{'exportIDEObj'}];
    end


    if any(strcmp(objProp,OptionsToBeDisabled))
        isEnabled=false;
    else
        isEnabled=true;
    end


    isEnabled=isEnabled&&~hSrc.isReadonlyProperty(objProp);