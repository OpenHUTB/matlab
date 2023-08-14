function buildProject(hbuild,varargin)
    switch hbuild.Vendor
    case 'Xilinx'
        soc.buildXilinxPrj(hbuild,varargin{:});
    case 'Intel'
        soc.buildIntelPrj(hbuild,varargin{:});
    end
end