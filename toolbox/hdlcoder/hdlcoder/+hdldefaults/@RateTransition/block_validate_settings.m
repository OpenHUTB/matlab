function v_settings=block_validate_settings(this,hC)%#ok<INUSD>







    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.checkenabledsubsystem=true;

    v_settings.checkretimeblackbox=true;


    v_settings.checksharing=false;


    v_settings.checkserialization=true;
    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;
    v_settings.checkmatrices=false;
end

