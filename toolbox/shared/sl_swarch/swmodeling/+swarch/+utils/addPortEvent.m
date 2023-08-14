function event=addPortEvent(eventChain,port,portEventType)



    ownerArch=eventChain.parent.p_Architecture;
    mdl=mf.zero.getModel(ownerArch);
    if strcmp(portEventType,'stimulus')
        eventChain.stimulus=...
        systemcomposer.architecture.model.traits.PortEvent.createPortEvent(...
        mdl,systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_RECEIVE,port);
        event=eventChain.stimulus;
    else
        eventChain.response=...
        systemcomposer.architecture.model.traits.PortEvent.createPortEvent(...
        mdl,systemcomposer.architecture.model.traits.EventTypeEnum.MESSAGE_SEND,port);
        event=eventChain.response;
    end
end
