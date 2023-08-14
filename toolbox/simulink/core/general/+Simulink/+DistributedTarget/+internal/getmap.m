function[output]=getmap(block,bd)







    mappings=get_param(block,'Mappings');

    output={};
    if~isempty(mappings)&&isa(mappings,'Simulink.SoftwareTarget.BlockToTaskMapping')
        archH=Simulink.DistributedTarget.internal.getmappingmgr(bd);
        bdname=get_param(bd,'Name');
        mapent=mappings.MappingEntities;
        output=cell(length(mapent),1);
        for i=1:length(mapent)
            output{i}=[bdname,Simulink.DistributedTarget.internal.getfullname(...
            archH,mapent(i))];
        end
    end
end