function algebraicConstraintBlock(obj)





    modelName=obj.modelName;
    objVersion=obj.ver;
    if isR2017aOrEarlier(objVersion)



        blkList=slexportprevious.utils.findBlockType(modelName,'AlgebraicConstraint','Constraint','f(z) = 0');
        if~isempty(blkList)
            obj.replaceWithLibraryLink(blkList,'simulink/Math\nOperations/Algebraic Constraint',...
            {'z0','InitialGuess'});
        end



        blkList=slexportprevious.utils.findBlockType(modelName,'AlgebraicConstraint','Constraint','f(z) = z');
        nb=length(blkList);
        for i=1:nb

            blk=blkList{i};
            z0=get_param(blk,'InitialGuess');
            obj.replaceBlock(blk,'built-in/InitialCondition','Value',z0);
        end
    end
end
