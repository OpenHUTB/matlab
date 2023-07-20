function setNFPConfiguration(this)
    newFPConfigReqd=0;
    latencyStrategy='Max';
    handleDenormals='Auto';
    mantMulStrategy='Auto';
    isNFPFlow=0;


    if strcmp(this.getCPObj.CLI.get('nativefloatingpoint'),'on')
        newFPConfigReqd=1;
        isNFPFlow=1;
    end

    curFPC=this.getCPObj.CLI.get('FloatingPointTargetConfiguration');
    if~isempty(curFPC)&&isa(curFPC,'hdlcoder.FloatingPointTargetConfig')
        if strcmpi(curFPC.Library,'NATIVEFLOATINGPOINT')
            latencyStrategy=curFPC.LibrarySettings.LatencyStrategy;
            handleDenormals=curFPC.LibrarySettings.HandleDenormals;
            mantMulStrategy=curFPC.LibrarySettings.MantissaMultiplyStrategy;
            isNFPFlow=1;
        end
    end


    if isNFPFlow

        cliLatency=this.getCPObj.CLI.get('nfpLatency');
        if~strcmpi(cliLatency,'DEFAULT')&&~strcmpi(cliLatency,latencyStrategy)
            latencyStrategy=cliLatency;
            newFPConfigReqd=1;
        end


        cliDenormal=this.getCPObj.CLI.get('nfpDenormals');
        if~strcmpi(cliDenormal,'DEFAULT')&&~strcmpi(cliDenormal,handleDenormals)
            handleDenormals=cliDenormal;
            newFPConfigReqd=1;
        end
    end

    if newFPConfigReqd==1
        fc=hdlcoder.createFloatingPointTargetConfig('NATIVEFLOATINGPOINT');
        fc.LibrarySettings.LatencyStrategy=latencyStrategy;
        fc.LibrarySettings.HandleDenormals=handleDenormals;
        fc.LibrarySettings.MantissaMultiplyStrategy=mantMulStrategy;
        this.getCPObj.CLI.set('FloatingPointTargetConfiguration',fc);
    end

end
