function map(blkhdl,bd,targets)





    try
        [archH,activemap]=Simulink.DistributedTarget.internal.getmappingmgr(bd);%#ok
        mappings=get_param(blkhdl,'Mappings');

        if~isempty(mappings)&&...
            isa(mappings,'Simulink.SoftwareTarget.BlockToTaskMapping')
            mappingent=mappings.MappingEntities;
        else
            mappingent=[];
        end


        if ischar(targets)
            targets={targets};
        end

        for i=1:length(targets)
            if~Simulink.DistributedTarget.internal.isvalidobj(targets{i})
                DAStudio.error('Simulink:mds:InvalidObjectIdentifier',targets{i});
            else
                archobj=strsplit(targets{i},'/');
                archTarget=Simulink.DistributedTarget.internal.getmappingmgr(archobj{1});
                handle=Simulink.DistributedTarget.internal.gethandle(...
                archobj(2:end),archTarget);
                inmapping=(mappingent==handle);
                if any(inmapping)


                    mappingent(inmapping)=[];
                else

                    activemap.map(blkhdl,handle);
                end
            end
        end


        for i=1:length(mappingent)
            activemap.unmap(blkhdl,mappingent(i));
        end

    catch err

        throwAsCaller(err);
    end
end


