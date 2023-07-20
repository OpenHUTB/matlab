function node=importImpl(fromFile)















    fromFile=pm_charvector(fromFile);
    node=simscape.logging.internal.node_import(fromFile);
end
