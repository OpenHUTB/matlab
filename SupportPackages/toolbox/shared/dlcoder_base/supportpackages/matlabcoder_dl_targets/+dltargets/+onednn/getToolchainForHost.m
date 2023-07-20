function tc=getToolchainForHost(dlcodeCfg)





    tcList=coder.make.internal.getHostToolchains;


    mexConfig=mex.getCompilerConfigurations('C++').Name;
    if contains(mexConfig,'MinGW64')
        mexConfig='MinGW64 | gmake (64-bit Windows)';
    elseif contains(mexConfig,'Clang')
        mexConfig='Clang';
    end



    tc=cellfun(@(toolchain)contains(toolchain,mexConfig),tcList);
    if~any(tc)
        error(message('dlcoder_spkg:cnncodegen:mex_setup_visual_studio'));
    end

    tc=tcList{tc};
end
