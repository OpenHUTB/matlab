function v_settings=block_validate_settings(~,~)




    v_settings=struct;

    v_settings.checkcomplex=false;

    v_settings.checkretimeblackbox=true;

    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode


        v_settings.checkportdatatypes=false;
    end
end
