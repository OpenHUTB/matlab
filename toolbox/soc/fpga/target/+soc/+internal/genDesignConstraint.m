function genDesignConstraint(hbuild)
    switch hbuild.Vendor
    case 'Xilinx'
        soc.genXilinxConstraint(hbuild);
    case 'Intel'
        soc.genIntelConstraint(hbuild);
    end
end