function name=getComponentDisplayName(rootArch,swc)





    fullname=getfullname(systemcomposer.utils.getSimulinkPeer(swc));
    name=regexprep(fullname,['^',rootArch.getName,'/'],'');
end
