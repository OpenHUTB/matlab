function[archH,varargout]=getmappingmgr(bd)







    try
        mgr=get_param(bd,'MappingManager');

        mapping=mgr.getActiveMappingFor('DistributedTarget');
        archH=mapping.Architecture;

        varargout{1}=mapping;
        varargout{2}=mgr;
    catch err

        throwAsCaller(err);
    end

end

