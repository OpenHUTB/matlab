function customCodeSettings=get_custom_code_settings(modelName,isRTW)



    if nargin<2
        isRTW=false;
    end

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName,isRTW);
