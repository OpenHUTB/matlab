function str=getLogAsSpecifiedInMdl(varargin)






    h=varargin{1};
    str='checked';


    mi=h.getModelLoggingInfo;
    if isempty(mi)
        return;
    end



    bpath=h.getFullMdlRefPath;
    if mi.getLogAsSpecifiedInModel(bpath.getBlock(1),false)
        str='checked';
        return;
    end




    if mi.modelHasOverrideSignals(bpath.getBlock(1))
        str='partial';
    else
        str='unchecked';
    end

end
