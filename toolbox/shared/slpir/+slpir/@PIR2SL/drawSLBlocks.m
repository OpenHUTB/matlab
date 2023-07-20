function drawSLBlocks(this,hPir)




    hRootN=hPir.getTopNetwork;
    if this.DUTMdlRefHandle>0
        srcParentPath=this.RootNetworkName;
    else
        srcParentPath=hRootN.FullPath;
    end
    if isempty(srcParentPath)
        srcParentPath=this.OutModelFile;
        hRootN.FullPath=this.RootNetworkName;
    end

    slpir.PIR2SL.clearNameMap;
    drawNetwork(this,srcParentPath,hRootN);
end

