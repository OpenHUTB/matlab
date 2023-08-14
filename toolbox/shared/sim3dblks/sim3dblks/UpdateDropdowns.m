function UpdateDropdowns(Block)
    if autoblkschecksimstopped(Block)
        if~bdIsLibrary(bdroot(Block))
            MaskObj=get_param(Block,'MaskObject');
            vehTag=MaskObj.getParameter('vehTag');

            SimVeh=sim3d.utils.SimPool.getActorList(bdroot(Block),'SimulinkVehicle');
            Custom=sim3d.utils.SimPool.getActorList(bdroot(Block),'Custom');
            vehTag.TypeOptions=unique([sort([SimVeh,Custom]),'Scene Origin']);
            vehTagList=MaskObj.getParameter('vehTagList');
            list=vehTag.TypeOptions;
            value='{';
            for listIndex=1:length(list)
                if listIndex>1
                    value=[value,';'];%#ok
                end
                value=[value,'''',list{listIndex},''''];%#ok
            end
            value=[value,'}'];
            vehTagList.Value=value;
        end
    end
end