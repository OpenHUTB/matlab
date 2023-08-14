function setTargetHardwareResourcesFromBlock(cs,block)




    info=get_param(block,'userData');

    if isfield(info,'chipInfo')&&isfield(info.chipInfo,'codegenhookpoint')
        info.tag=get_param(block,'Tag');
        set_param(cs,'TargetHardwareResources',info);
        adaptorName=linkfoundation.util.convertTPTagToAdaptorName(info.tag);
        if cs.isValidParam('AdaptorName')
            set_param(cs,'AdaptorName',adaptorName);
            hTgt=cs.getComponent('Code Generation').getComponent('Target');
            if~isequal(hTgt.AdaptorName,adaptorName)
                hTgt.setAdaptor(adaptorName);
            end
        end
    end
end
