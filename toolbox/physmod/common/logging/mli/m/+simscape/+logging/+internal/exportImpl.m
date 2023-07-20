function exportImpl(node,toFile)

















    toFile=pm_charvector(toFile);
    simscape.logging.internal.node_export(node,toFile);

end


