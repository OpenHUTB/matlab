function allocSet=createAllocationSet(name,sourceMdl,targetMdl)




    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    if((ischar(sourceMdl)||isstring(sourceMdl))&&...
        (ischar(targetMdl)||isstring(targetMdl)))
        allocSetImpl=appCatalog.createNewAllocationSet(name,...
        sourceMdl,targetMdl,"");
    elseif(isa(sourceMdl,'systemcomposer.arch.Model')&&...
        isa(targetMdl,'systemcomposer.arch.Model'))
        allocSetImpl=appCatalog.createNewAllocationSet(name,...
        sourceMdl.getImpl,targetMdl.getImpl,"");
    else
        error('Incorrect Type');
    end
    allocSet=systemcomposer.allocation.internal.getWrapperForImpl(allocSetImpl);

end

