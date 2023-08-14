function interpNdBlock(obj)







    blockType='Interpolation_n-D';

    UseRowMajorAlgorithmParamExists=true;
    try
        rowMajorAlg=get_param(obj.modelName,'UseRowMajorAlgorithm');
    catch


        UseRowMajorAlgorithmParamExists=false;
    end

    if isR2018aOrEarlier(obj.ver)&&...
        UseRowMajorAlgorithmParamExists&&strcmp(rowMajorAlg,'on')

        InterpNdBlks=slexportprevious.utils.findBlockType(obj.modelName,blockType);
        if(~isempty(InterpNdBlks))


            for i=1:length(InterpNdBlks)
                blk=InterpNdBlks{i};
                try
                    numSelDims=eval(get_param(blk,'NumSelectionDims'));
                catch
                    numSelDims=0;
                end
                if(numSelDims>0)


                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end


