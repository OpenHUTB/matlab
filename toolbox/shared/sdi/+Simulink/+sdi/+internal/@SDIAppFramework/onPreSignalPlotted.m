function onPreSignalPlotted(~,varargin)



    if~Simulink.sdi.Instance.isSDIRunning()
        repo=sdi.Repository(1);
        sigIDs=repo.getAllCheckedSignals();
        if isempty(sigIDs)
            Simulink.sdi.clearSignalsFromCanvas(int32.empty);
        end
    end

end
