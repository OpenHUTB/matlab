function v_settings=block_validate_settings(~,~)




    v_settings=struct;


    v_settings.checkretimeblackbox=true;


    v_settings.checksharing=true;


    v_settings.checkserialization=true;


    v_settings.checkcomplex=false;


    v_settings.checkmulticlock=true;

    v_settings.checknfp=false;
end
