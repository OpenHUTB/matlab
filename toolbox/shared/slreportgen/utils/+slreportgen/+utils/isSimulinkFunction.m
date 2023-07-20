function tf=isSimulinkFunction(blk)









    tf=false;
    try
        blkH=slreportgen.utils.getSlSfHandle(blk);
    catch
        return;
    end


    if isempty(blkH)||isa(blkH,"Stateflow.Object")||...
        ~strcmp(get_param(blkH,"type"),"block")||~strcmp(get_param(blkH,"blocktype"),"SubSystem")
        return
    end


    triggerPort=find_system(blkH,"SearchDepth",1,...
    "MatchFilter",@Simulink.match.allVariants,...
    "type","block","blocktype","TriggerPort");
    if~isempty(triggerPort)

        if strcmp(get_param(triggerPort,"IsSimulinkFunction"),"on")
            tf=true;
        else

            parent=get_param(blkH,"Parent");
            tf=strcmp(get_param(parent,"Type"),"block")&&...
            ~strcmp(get_param(parent,"SFBlockType"),"NONE");
        end
    end

end
