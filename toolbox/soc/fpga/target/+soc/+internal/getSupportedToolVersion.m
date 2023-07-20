function ver=getSupportedToolVersion(vendor)
    switch lower(vendor)
    case 'xilinx'
        ver='2020.2';
    case 'intel'
        ver='20.1.1';
    end
end