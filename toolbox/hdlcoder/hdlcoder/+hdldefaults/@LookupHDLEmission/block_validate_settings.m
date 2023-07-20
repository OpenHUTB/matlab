function v_settings=block_validate_settings(this,hC)







    v_settings=struct;



    v_settings.checkcomplex=false;


    v_settings.checkretimeincompatibility=true;



    v_settings.checksharing=true;


    v_settings.checkserialization=true;

    v_settings.incompatibleforxilinx=true;
    v_settings.incompatibleforaltera=true;

    v_settings.checknfp=true;
