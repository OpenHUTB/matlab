function ret=getClient(~,variant)
    ret=Simulink.sdi.internal.Util.getClientFromView(variant);
end