
function v_settings=block_validate_settings(this,hC)%#ok<INUSD>



    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.incompatibleforxilinx=true;
    v_settings.incompatibleforaltera=true;
    v_settings.checkmatrices=true;
    v_settings.maxsupporteddimension=2;
