





function issue_inv_comp_env_val_error(env,envVal,checkEnvVal,correctSetting)
    DAStudio.error('RTW:compilerConfig:invalidEnvVariable',...
    env,envVal,checkEnvVal,env,correctSetting,...
    fullfile(prefdir,'mexopts.bat'));

