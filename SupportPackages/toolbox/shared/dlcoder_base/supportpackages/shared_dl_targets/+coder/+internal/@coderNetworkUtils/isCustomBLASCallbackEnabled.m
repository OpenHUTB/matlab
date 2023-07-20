function p=isCustomBLASCallbackEnabled()





%#codegen

    coder.allowpcode('plain');

    cfg=eml_option('CodegenBuildContext');
    if~isempty(cfg)
        opt=coder.const(feval('getConfigProp',cfg,'CustomBLASCallback'));
        p=~isempty(opt)&&opt(1);
    else
        p=false;
    end

end
