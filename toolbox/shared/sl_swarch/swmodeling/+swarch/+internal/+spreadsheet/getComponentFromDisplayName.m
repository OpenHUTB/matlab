function swc=getComponentFromDisplayName(rootArch,displayname)





    blkh=get_param([rootArch.getName,'/',displayname],'Handle');
    swc=systemcomposer.utils.getArchitecturePeer(blkh);
end
