function v_settings=block_validate_settings(~,hC)




    v_settings=struct;


    v_settings.checkserialization=true;


    v_settings.checkcomplex=false;

    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;
    v_settings.checkmatrices=false;

    if~isempty(hC)&&isHalfType(hC.PirInputSignals(1).Type.BaseType)
        v_settings.incompatibleforxilinx=true;
        v_settings.incompatibleforaltera=true;
    end
end
