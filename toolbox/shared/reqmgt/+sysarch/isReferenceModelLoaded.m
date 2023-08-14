function b=isReferenceModelLoaded(blkHdl)




    b=false;
    elem=systemcomposer.utils.getArchitecturePeer(blkHdl);
    if elem.hasReferencedArchitecture
        refModelName=systemcomposer.internal.getReferenceName(blkHdl);
        if~isempty(systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel(refModelName))
            b=true;
        end
    end

end
