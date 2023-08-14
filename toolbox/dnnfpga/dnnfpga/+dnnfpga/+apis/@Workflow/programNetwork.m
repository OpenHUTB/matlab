function programNetwork(this,verbose)




    if nargin<2
        verbose=this.DefaultVerbose;
    end

    dn=this.DeployableNet;
    if(ischar(dn))
        dn=load(dn);
        dn=dn.deployableNW;
    end

    hPlatform=this.constructProcessorPlatform();
    fd=dnnfpga.bitstreambase.fpgaDeployment(dn,hPlatform);
    fd.init(verbose);
    fd.setupProfiler([]);

end
