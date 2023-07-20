function setPropValue(h,prop,val)




    assert(strcmp('logAsSpecifiedInMdl',prop));


    mi=h.getModelLoggingInfo;


    val=strcmp(val,'checked');
    bpath=h.getFullMdlRefPath;
    mi=mi.setLogAsSpecifiedInModel(bpath.getBlock(1),val);


    if~val
        mi=mi.removeSignalsForMdlBlock(...
        bpath.getBlock(1),...
        false);
    end


    h.setModelLoggingInfo(mi);


    h.firePropertyChange;
    h.refreshSignals;

end
