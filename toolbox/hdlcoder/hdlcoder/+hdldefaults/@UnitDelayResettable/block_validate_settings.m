function v_settings=block_validate_settings(~,~)




    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.checkportdatatypes=false;

    v_settings.checkretimeincompatibility=false;

    v_settings.incompatibleforaltera=true;
    v_settings.incompatibleforxilinx=true;
    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;
end
