function val=getAllColumns(h)








    val=h(1).getColumns;

    for ind=2:length(h)
        val=bitor(val,h(ind).getColumns);
    end


