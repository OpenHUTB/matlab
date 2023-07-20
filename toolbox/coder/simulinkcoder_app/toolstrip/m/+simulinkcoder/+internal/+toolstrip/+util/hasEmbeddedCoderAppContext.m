function[out]=hasEmbeddedCoderAppContext(cbinfo)

    context=cbinfo.studio.App.getAppContextManager.getCustomContext('embeddedCoderApp');

    if isa(context,'simulinkcoder.internal.toolstrip.context.EmbeddedCoderAppContext')
        out=true;
    else
        out=false;
    end

end

