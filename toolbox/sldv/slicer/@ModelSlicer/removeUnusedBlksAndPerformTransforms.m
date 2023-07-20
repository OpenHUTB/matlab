function modifiedSystems=removeUnusedBlksAndPerformTransforms(obj,groups,handles,origSys,sliceRootSys,post,sliceMdl,sliceXfrmr)




    import Transform.*;


    handles=groups.filterChildren(handles,obj.options);

    handlesCopy=getCopyHandles(handles,obj.refMdlToMdlBlk,origSys,sliceRootSys);


    updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:RemovingUnusedBlocks');
    redundantMerges=ModelSlicer.getRedundantMergeBlks(post);
    modifiedSystems=obj.removeUnusedBlocks(sliceXfrmr,sliceMdl,handlesCopy,redundantMerges,handles);


    updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:TransformingSliceModel');
    transformRules=obj.transforms;
    for i=1:length(transformRules)
        transformRules(i).transformCopy(sliceXfrmr,obj.refMdlToMdlBlk,origSys,sliceRootSys);
    end

    for i=1:length(post)
        post(i).transformCopy(sliceXfrmr,obj.refMdlToMdlBlk,origSys,sliceRootSys);
    end

end
