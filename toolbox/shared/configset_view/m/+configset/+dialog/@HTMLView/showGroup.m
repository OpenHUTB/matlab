function showGroup(obj,comp)





    comp=configset.internal.util.convertShowGroupInput(comp);

    if obj.isWebPageReady
        obj.publish('showGroup',comp);
    else
        obj.deferredMsgs{end+1}={'showGroup',comp};
    end
