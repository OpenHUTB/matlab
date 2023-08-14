function v_settings=get_validate_settings(this,hC)


















    v_settings=this.base_validate_settings;


    v_override_settings=this.block_validate_settings(hC);
    f=fields(v_override_settings);

    for n=1:numel(f)

        v_settings.(lower(f{n}))=v_override_settings.(f{n});
    end


