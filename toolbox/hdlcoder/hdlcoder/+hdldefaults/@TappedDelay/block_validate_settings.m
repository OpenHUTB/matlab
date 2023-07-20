function v_settings=block_validate_settings(~,~)







    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.checkretimeincompatibility=false;



    v_settings.checksharing=false;


    v_settings.checkserialization=true;

    v_settings.incompatibleforxilinx=false;
    v_settings.incompatibleforaltera=false;
    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;
    v_settings.checkmatrices=false;
