function tcList=getFilteredToolchains(cs)









    configSet=cs.getConfigSet();
    if isempty(configSet)


        filter=coder.make.internal.ToolchainListFilter.empty;
    else
        filter=configset.internal.util.ToolchainListFilter(configSet);
    end
    tcList=coder.make.internal.guicallback.getToolchains(filter);

end