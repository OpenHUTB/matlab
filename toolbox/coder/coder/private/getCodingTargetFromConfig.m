function target=getCodingTargetFromConfig(configInfo)



    switch class(configInfo)
    case{'coder.MexConfig','coder.MexCodeConfig'}
        target='mex';
    case{'coder.CodeConfig','coder.EmbeddedCodeConfig'}
        target=['rtw:',lower(configInfo.OutputType)];
    otherwise
        target='mex';
    end
end