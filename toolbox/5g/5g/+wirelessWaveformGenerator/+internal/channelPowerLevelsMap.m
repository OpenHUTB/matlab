function[powerLevelMap,colorScale,cmap]=channelPowerLevelsMap()

    persistent pLevelMap scaling colorMap;

    if isempty(pLevelMap)
        ssbNames=["nrWavegenSSBurstConfig","SSBurst","SS Burst","SS_Burst","SSB"];
        pxschNames=["nrWavegenPDSCHConfig","PDSCH","nrWavegenPUSCHConfig","PUSCH","PXSCH"];
        pxschDMRSNames=["nrPDSCHDMRSConfig","PDSCH_DMRS","nrPUSCHDMRSConfig","PUSCH_DMRS"];
        pxschPTRSNames=["nrPDSCHPTRSConfig","PDSCH_PTRS","nrPUSCHPTRSConfig","PUSCH_PTRS"];
        pxcchNames=["nrWavegenPDCCHConfig","nrWavegenPUCCH0Config","nrWavegenPUCCH1Config",...
        "nrWavegenPUCCH2Config","nrWavegenPUCCH3Config","nrWavegenPUCCH4Config",...
        "PDCCH","PUCCH","PXCCH"];
        pxcchDMRSNames=["PDCCH_DMRS","PUCCH_DMRS"];

        rsNames=["nrWavegenCSIRSConfig","nrWavegenSRSConfig","CSIRS","SRS"];
        csetNames=["nrCORESETConfig","CORESET"];
        bwpNames=["nrWavegenBWPConfig","BWP"];
        bckgroundNames="Background";

        ssbLevel=0.39;
        pxschLevel=0.51;
        pxschDMRSLevel=0.75;
        pxschPTRSLevel=0.3;
        pxcchLevel=0.83;
        pxcchDMRSLevel=0.45;
        rsLevel=0.9;
        csetLevel=0.7;
        bwpLevel=0.15;
        bckgroundColor=0;

        chNames=[ssbNames,pxschNames,pxschDMRSNames,pxschPTRSNames,...
        pxcchNames,pxcchDMRSNames,rsNames,csetNames,bwpNames,...
        bckgroundNames];
        chpLevels=[repmat(ssbLevel,1,length(ssbNames)),...
        repmat(pxschLevel,1,length(pxschNames)),...
        repmat(pxschDMRSLevel,1,length(pxschDMRSNames)),...
        repmat(pxschPTRSLevel,1,length(pxschPTRSNames)),...
        repmat(pxcchLevel,1,length(pxcchNames)),...
        repmat(pxcchDMRSLevel,1,length(pxcchDMRSNames)),...
        repmat(rsLevel,1,length(rsNames)),...
        repmat(csetLevel,1,length(csetNames)),...
        repmat(bwpLevel,1,length(bwpNames)),...
        repmat(bckgroundColor,1,length(bckgroundNames))];%#ok<REPMAT> 

        pLevelMap=containers.Map(chNames,chpLevels);
        colorMap=parula(256);
        scaling=length(colorMap);

    end

    powerLevelMap=pLevelMap;
    colorScale=scaling;
    cmap=colorMap;

end