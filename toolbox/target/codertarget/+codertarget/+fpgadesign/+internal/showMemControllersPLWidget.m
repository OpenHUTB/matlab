function out=showMemControllersPLWidget(hObj,varargin)



    hCS=hObj.getConfigSet();

    depParam='FPGADesign.HasPLMemory';
    if codertarget.data.isParameterInitialized(hCS,depParam)
        out=codertarget.data.getParameterValue(hCS,depParam);
    else
        out=0;
    end
end


