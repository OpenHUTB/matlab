function v_settings=block_validate_settings(this,~)



    v_settings=this.base_validate_settings;
    v_settings.checkportdatatypes;

    v_settings.incompatibleforxilinx=true;
    v_settings.incompatibleforaltera=true;
end
