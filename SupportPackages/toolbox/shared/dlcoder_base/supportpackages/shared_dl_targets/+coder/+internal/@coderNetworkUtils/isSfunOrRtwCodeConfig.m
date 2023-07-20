function p=isSfunOrRtwCodeConfig()





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    cfg=eml_option('CodegenBuildContext');
    buildWorkflow=coder.const(@feval,'dlcoder_base.internal.getBuildWorkflow',cfg);

    p=coder.const(strcmp(buildWorkflow,'simulation ')...
    ||strcmp(buildWorkflow,'simulink'));

end