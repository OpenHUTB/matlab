function highlightInModel(id)

    engine=Simulink.sdi.Instance.engine;
    runID=engine.getSignalRunID(id);
    topModel=stm.internal.getRunModel(runID,int32(0));
    harnessField=stm.internal.getRunModel(runID,int32(1));
    ind=strfind(harnessField,'%%%');
    if(~isempty(ind))
        harnessName=harnessField(1:ind(1)-1);
        ownerName=harnessField(ind(1)+3:end);

        open_system(topModel);

        try
            sltest.harness.open(ownerName,harnessName);
        catch
            error(message('stm:general:SignalNotFound'));
        end
    end

    [~,val]=engine.showSourceBlockInModel(id);
    if(~isempty(val)&&~val)
        error(message('stm:general:SignalNotFound'));
    end
end