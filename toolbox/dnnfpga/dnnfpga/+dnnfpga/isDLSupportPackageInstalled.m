function isInstalled=isDLSupportPackageInstalled(spID)




    switch lower(spID)
    case "shared"
        isInstalled=isequal(exist('dltargets.internal.NetworkInfo','class'),8);
    case 'xilinx'
        isInstalled=isequal(exist('dnnfpga.tool.XilinxSupportPackage','class'),8);
    case 'intel'
        isInstalled=isequal(exist('dnnfpga.tool.IntelSupportPackage','class'),8);
    otherwise
        isInstalled=false;
    end

end


