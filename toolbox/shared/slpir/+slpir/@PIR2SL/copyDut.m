function copyDut(this)

    this.genmodeldisp(sprintf('Start Layout...'),3);

    inDut=this.RootNetworkName;
    inMdlFileName=this.InModelFile;

    if strcmp(inDut,inMdlFileName)
        return;
    end

    outDut=regexprep(inDut,['^',this.InModelFile],this.OutModelFile);
    add_block(inDut,outDut);
end
