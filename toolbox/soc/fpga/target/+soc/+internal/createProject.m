function createProject(hbuild,varargin)
    switch hbuild.Vendor
    case 'Xilinx'
        soc.createXilinxPrj(hbuild,varargin{:});
    case 'Intel'
        soc.createIntelPrj(hbuild,varargin{:});
    end
end