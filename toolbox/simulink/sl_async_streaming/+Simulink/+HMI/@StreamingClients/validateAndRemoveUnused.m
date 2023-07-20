function validateAndRemoveUnused(this)



    len=this.Count;
    for idx=len:-1:1
        client=get(this,idx);
        if~strcmp(client.getTopModel(),this.Model)
            remove(this,idx);
            MSLDiagnostic(...
            'Simulink:HMI:ModelObsSignalNotInMdl',...
            this.Model,...
            idx).reportAsWarning;
        elseif Simulink.HMI.SignalInterface.observerIsNotUsed(client)
            remove(this,idx);
        end

    end
end
