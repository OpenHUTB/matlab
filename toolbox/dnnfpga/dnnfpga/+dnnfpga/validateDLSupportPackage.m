function validateDLSupportPackage(spID,kind)




    if nargin<2
        kind='default';
    end
    if~dnnfpga.isDLSupportPackageInstalled(spID)
        switch(lower(kind))
        case 'multiple'
            msg=message('dnnfpga:workflow:SupportPackageMissingShared',dnnfpga.apis.verboseNameHSP('Intel'),dnnfpga.apis.verboseNameHSP('Xilinx'));
        case 'buildProcessor'
            msg=message('dnnfpga:workflow:SupportPackageMissingForBuildProcessor',spID,dnnfpga.apis.verboseNameHSP(spID));
        case 'target'
            msg=message('dnnfpga:workflow:SupportPackageMissingForTarget',spID,dnnfpga.apis.verboseNameHSP(spID));
        case 'bitstream'
            msg=message('dnnfpga:workflow:SupportPackageMissingForBitstream',spID,dnnfpga.apis.verboseNameHSP(spID));
        otherwise
            msg=message('dnnfpga:workflow:SupportPackageMissing',dnnfpga.apis.verboseNameHSP(spID));
        end
        error(msg);
    end
end

