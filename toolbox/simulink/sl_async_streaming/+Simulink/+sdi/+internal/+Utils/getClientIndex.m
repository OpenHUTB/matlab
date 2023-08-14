


function[idxs,wasAdded]=getClientIndex(clients,sigInfo,observerType)


    sig=struct;
    import Simulink.sdi.internal.ObserverInterface;
    mdl=sigInfo.mdl;
    if isfield(sigInfo,'portH')
        portH=sigInfo.portH;
        sig.OutputPortIndex=get(portH,'PortNumber');
        sig.BlockPath=Simulink.BlockPath(get_param(portH,'Parent'));
    else
        sig.OutputPortIndex=sigInfo.OutputPortIndex;
        sig.BlockPath=Simulink.BlockPath(sigInfo.BlockPath);
    end
    [idxs,~]=ObserverInterface.getClientIndex(mdl,sig,observerType);
    if isempty(idxs)
        Simulink.sdi.internal.Utils.addNewClient(clients,mdl,sig,observerType);
        idxs={clients.Count};
        wasAdded=true;
    else
        wasAdded=false;
    end
end

