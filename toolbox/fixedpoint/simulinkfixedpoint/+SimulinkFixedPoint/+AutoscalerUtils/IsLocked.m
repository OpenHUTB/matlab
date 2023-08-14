function isLocked=IsLocked(blockObject)












    isLocked=false;

    if isprop(blockObject,'LockScale')


        isLocked=strcmp(blockObject.LockScale,'on');

    elseif isa(blockObject,'Stateflow.Data')


        isLocked=blockObject.Props.Type.Fixpt.Lock;

    end

    if~isLocked&&SimulinkFixedPoint.AutoscalerUtils.hasGetParent(blockObject)



        blockParent=blockObject.getParent;



        if~isempty(blockParent)&&isprop(blockParent,'LockScale')


            isLocked=strcmp(blockParent.LockScale,'on');
        end






    end

end



