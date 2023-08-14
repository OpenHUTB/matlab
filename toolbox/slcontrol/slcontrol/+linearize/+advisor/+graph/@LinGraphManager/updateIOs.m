function this=updateIOs(this,J,iostruct)




    import linearize.advisor.highlighter.*

    this=updateGraphs(this,updateIOs(this.ChannelGraph,J,iostruct),true);

    handles=J.Mi.BlockHandles;

    this.JStructuralBlocks=handles(J.Mi.ForwardMark&J.Mi.BackwardMark);
    this.JNumericalBlocks=handles(J.Mi.BlocksInPath);

    this.MinimalChannelGraph=getMinimalChannelGraph(this);

    this=buildPathHighlighters(this);
