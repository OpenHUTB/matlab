function isEnabled=getEnabledFlag(hSrc,objProp)













    OptionsToBeDisabled={};


    switch(hSrc.ProfileGenCode)
    case 'on'


        OptionsToBeDisabled={'exportIDEObj'};
    end


    if any(strcmp(objProp,OptionsToBeDisabled))
        isEnabled=false;
    else
        isEnabled=true;
    end


    isEnabled=isEnabled&&~hSrc.isReadonlyProperty(objProp);