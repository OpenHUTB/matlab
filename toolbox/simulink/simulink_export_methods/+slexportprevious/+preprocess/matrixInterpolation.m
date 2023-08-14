function matrixInterpolation(obj)






    blkType='MatrixInterpolation';

    if isR2015bOrEarlier(obj.ver)
        oldFeatureValue=slfeature('FindSystemUseUnifiedBlockType',1);
        MatrixInterpBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        slfeature('FindSystemUseUnifiedBlockType',oldFeatureValue);
        if(isempty(MatrixInterpBlks))
            return;
        end

        obj.replaceWithEmptySubsystem(MatrixInterpBlks);
    end

end
