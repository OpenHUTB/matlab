function genDesignTcl(hbuild)
    switch hbuild.Vendor
    case 'Xilinx'
        soc.genXilinxDesignTcl(hbuild);
    case 'Intel'
        soc.genIntelDesignTcl(hbuild);
    end
end