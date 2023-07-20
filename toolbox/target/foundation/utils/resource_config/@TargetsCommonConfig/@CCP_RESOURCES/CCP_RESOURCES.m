function h=CCP_RESOURCES(varargin)





    h=TargetsCommonConfig.CCP_RESOURCES;



    type=findtype('CCP_INSTANCE_FLAG');
    h.CCP_INSTANCE=RTWConfiguration.Resource(type.Strings);
