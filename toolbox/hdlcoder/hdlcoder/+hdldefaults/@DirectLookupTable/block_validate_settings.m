function v_settings=block_validate_settings(this,~)





    v_settings=this.base_validate_settings;
    v_settings.checkcomplex=false;
    v_settings.incompatibleforxilinx=true;
    v_settings.incompatibleforaltera=true;
    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;
end
