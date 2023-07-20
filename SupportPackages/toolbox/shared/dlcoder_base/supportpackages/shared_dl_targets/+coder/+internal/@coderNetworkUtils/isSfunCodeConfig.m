function p=isSfunCodeConfig()





%#codegen

    coder.allowpcode('plain');

    cfg=eml_option('CodegenBuildContext');

    if~isempty(cfg)
        opt=coder.const(feval('isCodeGenTarget',cfg,'sfun'));
        p=~isempty(opt)&&opt(1);
    else
        p=false;
    end

end