function syncDimensions(paramDef,slVar,doWarning)

    if isa(slVar,'Simulink.Parameter')
        dims=slVar.Dimensions;
    else
        dims=size(slVar);
    end
    if(numel(dims)>2)
        if doWarning

            warning('SystemArchitecture:Parameter:UnsupportedParamDimension',...
            DAStudio.message(...
            'SystemArchitecture:Parameter:UnsupportedParamDimension',...
            maName,mdlName));
        end
        paramDef.destroy;
    else
        paramDef.getImpl.setDimensions(uint64(dims));
    end
end