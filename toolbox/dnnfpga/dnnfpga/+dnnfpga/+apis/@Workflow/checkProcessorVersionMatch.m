function checkProcessorVersionMatch(this)









    currentProcessorVersion=dnnfpga.processorVersion;
    matFileProcessorVersion=this.hBitstream.getProcessorVersion;


    currentProcessorVersionNumber=downstream.tool.getToolVersionNumber(currentProcessorVersion);
    matFileProcessorVersionNumber=downstream.tool.getToolVersionNumber(matFileProcessorVersion);

    if currentProcessorVersionNumber==matFileProcessorVersionNumber

        return;
    end


    currentMATLABVersion=version;
    matFileMATLABVersion=this.hBitstream.getMATLABVersion;

    if currentProcessorVersionNumber>matFileProcessorVersionNumber






        error(message('dnnfpga:workflow:BitstreamVersionOlder',matFileMATLABVersion,currentMATLABVersion));

    elseif currentProcessorVersionNumber<matFileProcessorVersionNumber






        error(message('dnnfpga:workflow:BitstreamVersionNewer',matFileMATLABVersion,currentMATLABVersion));

    end

end
