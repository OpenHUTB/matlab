function startLayout(this)







    this.genmodeldisp(sprintf('Start Layout...'),3);
    if this.isDutWholeModel
        return;
    end

    outDut=regexprep(this.RootNetworkName,['^',this.InModelFile],this.OutModelFile);
    add_block('built-in/Subsystem',outDut);
end
