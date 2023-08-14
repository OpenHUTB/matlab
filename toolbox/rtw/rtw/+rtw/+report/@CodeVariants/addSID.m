function addSID(obj)
    data=obj.Data;
    for vg=1:data.NumCodeVariantGroups
        if data.NumCodeVariantGroups==1
            group=data.CodeVariantGroup;
        else
            group=data.CodeVariantGroup{vg};
        end
        group.NonExpandedBlockSID=Simulink.ID.getSID(group.NonExpandedBlockPath);
        group.NonExpandedBlockType=get_param(group.NonExpandedBlockPath,'BlockType');
        if data.NumCodeVariantGroups==1
            data.CodeVariantGroup=obj.addSIDToVariantGroup(group);
        else
            data.CodeVariantGroup{vg}=obj.addSIDToVariantGroup(group);
        end
    end
    if isfield(data,'NumSimulinkVariantObjects')&&data.NumSimulinkVariantObjects>0
        if~iscell(data.SimulinkVariantObject)
            data.SimulinkVariantObject={data.SimulinkVariantObject};
        end
        indx2Remove=[];
        for vo=1:data.NumSimulinkVariantObjects
            if isfield(data.SimulinkVariantObject{vo},'ReferencedByBlockPaths')
                data.SimulinkVariantObject{vo}=obj.addSIDToVariantObject(data.SimulinkVariantObject{vo});
            else
                indx2Remove=[indx2Remove,vo];
            end
        end
        data=obj.updateData(data,indx2Remove);
    end
    obj.Data=data;
end

