function out=showMemControllersPSWidget(hObj,varargin)



    hCS=hObj.getConfigSet();

    depParam1='FPGADesign.HasPSMemory';
    depParam2='FPGADesign.IncludeProcessingSystem';
    if codertarget.data.isParameterInitialized(hCS,depParam1)&&...
        codertarget.data.isParameterInitialized(hCS,depParam2)
        out=codertarget.data.getParameterValue(hCS,depParam1)&&...
        codertarget.data.getParameterValue(hCS,depParam2);
    else
        out=0;
    end
end


