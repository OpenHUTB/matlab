function setDefaultTargetHardwareResources(cs)




    if ispc
        if exist('registertic2000.m','file')
            data=targetpref.Data(cs,[],'ccslinktgtpref');
        elseif exist('registerxilinxise.m','file')
            data=targetpref.Data(cs,[],'xilinxisetgtpref');
        end
    else
        if exist('registertic2000.m','file')
            data=targetpref.Data(cs,[],'ccslinktgtpref_ccsv5');
        end
    end

    info=data.getDefaultTargetInfo();
    info=data.reduceTargetInfo(info);
    set_param(cs,'TargetHardwareResources',info);
    adaptorName=linkfoundation.util.convertTPTagToAdaptorName(info.tag);
    set_param(cs,'AdaptorName',adaptorName);
    hTgt=cs.getComponent('Code Generation').getComponent('Target');
    hTgt.setAdaptor(adaptorName);
end
