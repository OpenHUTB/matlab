function tf=isConfigurableSubsystemBlock(obj)








    tf=false;
    if~isempty(obj)
        try
            objH=slreportgen.utils.getSlSfObject(obj);
            tf=isa(objH,'Simulink.SubSystem')&&~isempty(objH.BlockChoice);
        catch
            return
        end
    end
end

