function checkArmComputeMALIParams(coderCfg,dlConfig,isdlcodegen)





    if nargin<3
        isdlcodegen=false;
    end

    assert(isa(dlConfig,'coder.ARMMALIConfig'));

    if isdlcodegen
        coderCfg.GenCodeOnly=true;
    else
        error(message('dnn_core:cnncodegen:InvalidCodegenWorkflow',...
        dlConfig.TargetLibrary,...
        'cudnn, tensorrt, mkldnn, arm-compute and none'));
    end

end


