function new_lims=constrainNormalizedLimitsToDimensions(orig_lims,dimensions)




    new_lims=[0,1,0,1,0,1];
    if dimensions.contains("x")
        new_lims(1:2)=orig_lims(1:2);
    end
    if dimensions.contains("y")
        new_lims(3:4)=orig_lims(3:4);
    end
    if dimensions.contains("z")
        new_lims(5:6)=orig_lims(5:6);
    end

