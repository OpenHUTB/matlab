function out=hasExplicitPartitions(bd)




    tcg=sltp.TaskConnectivityGraph(bd);
    out=tcg.hasExplicitPartitions();

end
