function ret=isSoCInstalledAndModelConfiguredForSoC(hObj,varargin)






    esbReqCap=1;
    if nargin>1
        esbReqCap=varargin{1};
    end

    ret=codertarget.utils.isSoCInstalled()&&...
    codertarget.targethardware.isESBCompatible(hObj,esbReqCap)&&...
    codertarget.utils.isMdlConfiguredForSoC(hObj);
end