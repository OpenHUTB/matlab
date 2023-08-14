function sysLibPath=getMLSysPath(mexToolChainName)



    switch mexToolChainName
    case{'g++'}
        sysLibPath=fullfile(matlabroot,'bin',computer('arch'));
    case{'Microsoft'}
        sysLibPath=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
    case{'Apple'}
        assert(false,...
        message('dlcoder_spkg:cnncodegen:UnsupportedInstrumentationOnMac'));
        sysLibPath='';
    otherwise
        assert(isempty(mexToolChainName),...
        message('dlcoder_spkg:cnncodegen:CodeGenWithInstrumentationFailed',mexToolChainName));
        sysLibPath='';
    end
end
