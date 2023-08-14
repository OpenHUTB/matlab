function p=isMexCodeConfig()





%#codegen

    coder.allowpcode('plain');

    cfg=eml_option('CodegenBuildContext');

    if~isempty(cfg)
        opt=coder.const(feval('isCodeGenTarget',cfg,'mex'));
        p=~isempty(opt)&&opt(1);
    else
        p=false;
    end

end
