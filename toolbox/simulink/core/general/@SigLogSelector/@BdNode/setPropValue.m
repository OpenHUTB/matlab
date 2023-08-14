function setPropValue(h,prop,val)




    assert(strcmp('logAsSpecifiedInMdl',prop));


    mi=h.getModelLoggingInfo;


    val=strcmp(val,'checked');
    mi=mi.setLogAsSpecifiedInModel(h.getBdRoot,val);


    if~val
        mi=mi.removeSignalsForTopMdl();
    end


    h.setModelLoggingInfo(mi);


    h.firePropertyChange;
    h.refreshSignals;

end
