function matrixLibraryBlocks(obj)




    if isReleaseOrEarlier(obj.ver,'R2021b')

        allBlksHermitian=locFindBlock(obj.modelName,'BlockType','IsHermitian');
        obj.replaceWithEmptySubsystem(allBlksHermitian);

        if~isspblksinstalled
            blkTypeDSP={'Submatrix','Permute Matrix','Create Diagonal Matrix','Extract Diagonal'};
            for i=1:numel(blkTypeDSP)
                allBlksOfThisType=locFindBlock(obj.modelName,'MaskType',blkTypeDSP{i});
                obj.replaceWithEmptySubsystem(allBlksOfThisType);
            end
        end
    end


    if isReleaseOrEarlier(obj.ver,'R2021a')
        blkTypeR2021a={'IdentityMatrix','IsTriangular','IsSymmetric'};
        for i=1:numel(blkTypeR2021a)
            allBlksOfAType=locFindBlock(obj.modelName,'BlockType',blkTypeR2021a{i});
            obj.replaceWithEmptySubsystem(allBlksOfAType);
        end


        allBlks=locFindBlock(obj.modelName,'MaskType','CrossProduct');
        obj.replaceWithEmptySubsystem(allBlks);




        allBlksTranspose=locFindBlock(obj.modelName,'MaskType','Transpose');
        for i=1:numel(allBlksTranspose)
            blk=allBlksTranspose{i};
            orient=get_param(blk,'Orientation');
            pos=get_param(blk,'Position');
            delete_block(blk);

            add_block('built-in/Math',blk,'Operator','transpose',...
            'Name','Transpose',...
            'Orientation',orient,...
            'Position',pos);
        end

        allBlksHermitian=locFindBlock(obj.modelName,'MaskType','HermitianTranspose');
        for i=1:numel(allBlksHermitian)
            blk=allBlksHermitian{i};
            orient=get_param(blk,'Orientation');
            pos=get_param(blk,'Position');
            delete_block(blk);

            add_block('built-in/Math',blk,'Operator','hermitian',...
            'Name','Hermitian',...
            'Orientation',orient,...
            'Position',pos);
        end





        if~isspblksinstalled
            allBlksMatSquare=locFindBlock(obj.modelName,'MaskType','Matrix Square');
            obj.replaceWithEmptySubsystem(allBlksMatSquare);
        end


    end

    function b=isspblksinstalled


        b=issimulinkinstalled;

        if b
            b=license('test','Signal_Blocks')&&~isempty(ver('dsp'));
        end
    end
    function b=issimulinkinstalled


        b=license('test','SIMULINK')&&~isempty(ver('simulink'));
    end

    function foundBlocks=locFindBlock(modelName,varargin)


        p=inputParser;
        p.addRequired('modelName',@isscalarstring);
        p.parse(modelName);
        function b=isscalarstring(v)
            b=ischar(v)||(isstring(v)&&numel(v)==1);
        end

        foundBlocks=find_system(modelName,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'IncludeCommented','on',...
        varargin{:});
    end
end
