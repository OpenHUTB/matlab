function v_settings=block_validate_settings(~,~)






    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.checkenabledsubsystem=true;

    v_settings.checkserialization=true;


    v_settings.checksingleratesharing=true;

    v_settings.checkportdatatypes=false;


    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
