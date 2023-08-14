




function str=writeIFDataXCPInfo(ifDataXcp,baseIndent,indentSpacing)

    ifDataXcpFileLevel=asam.mcd2mc.Transformer.ToFileLevel(ifDataXcp);
    mf0Model=asam.mcd2mc.ObjectFactory.getModel();
    mf0Writer=asam.mcd2mc.Writer(mf0Model);
    mf0Writer.BaseIndent=baseIndent;
    mf0Writer.IndentSpacing=indentSpacing;
    str=mf0Writer.write(ifDataXcpFileLevel);

end