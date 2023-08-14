function nfpMode=isNativeFloatingPointMode()
    fpConfig=hdlgetparameter('FloatingPointTargetConfiguration');
    nfpMode=0;
    if~isempty(fpConfig)
        nfpMode=strcmpi(fpConfig.Library,'NATIVEFLOATINGPOINT');
    end
end
