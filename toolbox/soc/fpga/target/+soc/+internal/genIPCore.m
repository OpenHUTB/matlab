function genIPCore(hbuild,varargin)
    switch hbuild.Vendor
    case 'Xilinx'
        soc.genXilinxIPCore(hbuild,varargin{:});
    case 'Intel'
        soc.genIntelIPCore(hbuild,varargin{:});
    end
end