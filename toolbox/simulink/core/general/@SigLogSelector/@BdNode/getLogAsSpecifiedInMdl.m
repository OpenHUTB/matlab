function str=getLogAsSpecifiedInMdl(varargin)






    h=varargin{1};
    str='checked';


    bdName=h.getBdRoot;
    if~strcmp(bdName,h.Name)
        return;
    end


    mi=h.getModelLoggingInfo;
    if isempty(mi)
        return;
    end


    if mi.getLogAsSpecifiedInModel(bdName)
        str='checked';
        return;
    end




    if mi.modelHasOverrideSignals();
        str='partial';
    else
        str='unchecked';
    end

end
