function docRoot=getDocRoot(spID)

    if nargin<1
        spID='';
    end

    switch lower(spID)
    case 'xilinx'

        docRoot=dnnfpga.tool.getDocRootXilinx;
    case 'intel'

        docRoot=dnnfpga.tool.getDocRootIntel;
    otherwise
        docRoot=fullfile(docroot,'deep-learning-hdl');
    end
end