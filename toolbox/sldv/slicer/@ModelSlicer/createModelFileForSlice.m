function[origSys,sliceRootSys,deadBlocks,toRemove,allNonVirtH]=createModelFileForSlice(obj,sliceMdl,sliceFileName,toRemove,allNonVirtH,deadBlocksMapped,deadBlocks)




    origSys=obj.model;
    mdlpath=which(origSys);
    if~obj.isSubsystemSlice
        if bdIsDirty(obj.modelH)
            slInternal('snapshot_slx',origSys,sliceFileName);
        else
            [ok,msg]=copyfile(mdlpath,sliceFileName,'f');
            if~ok
                error('ModelSlicer:CannotWriteFile',getString(message('Sldv:ModelSlicer:ModelSlicer:CannotWriteModelFile',msg)));
            end
        end

        [ok,msg]=fileattrib(sliceFileName,'+w');
        if~ok
            error('ModelSlicer:CannotWriteFile',getString(message('Sldv:ModelSlicer:ModelSlicer:CannotWriteModelFile',msg)));
        end
        sliceRootSys=sliceMdl;
    else


        Transform.SubsystemSliceUtils.checkCompatibility(...
        obj.sliceSubSystemH,toRemove,true);


        [ssIOActivity,deadBlocks]=Transform.SubsystemSliceUtils.deriveInterfaceActivity(obj,deadBlocksMapped,deadBlocks);


        validHdl=obj.getSystemAllDescendants();
        toRemove=intersect(toRemove,validHdl);
        allNonVirtH=intersect(allNonVirtH,validHdl);


        [origSys,sliceRootSys]=Transform.SubsystemSliceUtils.generateModelForSubsystemSlice(...
        sliceFileName,ssIOActivity,obj);
    end
end
