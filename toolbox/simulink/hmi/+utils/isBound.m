

function result=isBound(HMIBlockHandle)

    result=false;
    isCoreBlock=false;
    if(strcmp(get_param(HMIBlockHandle,'isCoreWebBlock'),'on'))
        isCoreBlock=true;
    end
    if(isCoreBlock)
        binding=get_param(HMIBlockHandle,'Binding');
    else
        widgetID=utils.getInstanceId(get_param(HMIBlockHandle,'Object'));
        isLibWidget=utils.getIsLibWidget(get_param(HMIBlockHandle,'Object'));
        binding=utils.getBoundElement(get_param(bdroot(HMIBlockHandle),'Name'),widgetID,isLibWidget);
    end
    if(~isempty(binding))
        result=true;
    end
end