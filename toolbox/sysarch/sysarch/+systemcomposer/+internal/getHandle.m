function handle=getHandle(pathOrElem)






    if isempty(pathOrElem)||isa(pathOrElem,'double')
        handle=pathOrElem;
    elseif isa(pathOrElem,'char')
        handle=get_param(pathOrElem,'Handle');
    else
        elemImpl=pathOrElem;
        if isa(pathOrElem,'systemcomposer.arch.Element')
            elemImpl=pathOrElem.getImpl;
        end



        if isa(elemImpl,'systemcomposer.architecture.model.design.Architecture')
            rootArch=systemcomposer.internal.getWrapperForImpl(elemImpl);
            handle=rootArch.SimulinkHandle;
            return;
        end

        handle=systemcomposer.utils.getSimulinkPeer(elemImpl);
    end
end