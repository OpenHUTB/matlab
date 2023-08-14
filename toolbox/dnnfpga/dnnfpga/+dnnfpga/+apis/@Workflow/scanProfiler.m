function profRawLogs=scanProfiler(this,options)




    dn=this.DeployableNet;
    if(ischar(dn))
        dn=load(dn);
        dn=dn.deployableNW;
    end

    hPlatform=this.constructProcessorPlatform();
    fd=dnnfpga.bitstreambase.fpgaDeployment(dn,hPlatform);
    profRawLogs=fd.scanProfiler(options);

end
