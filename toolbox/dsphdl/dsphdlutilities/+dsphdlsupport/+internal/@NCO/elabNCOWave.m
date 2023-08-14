function waveNet=elabNCOWave(this,topNet,blockInfo,dataRate)




    outMode=blockInfo.outMode;
    outcase=outMode(1)+2*outMode(2)+4*outMode(3);

    if outcase>=3&&~(blockInfo.LUTCompress)
        waveNet=this.elabNCOWaveD(topNet,blockInfo,dataRate);
    else
        waveNet=this.elabNCOWaveS(topNet,blockInfo,dataRate);
    end

end
