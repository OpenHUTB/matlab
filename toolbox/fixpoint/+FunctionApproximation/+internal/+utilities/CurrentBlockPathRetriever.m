classdef CurrentBlockPathRetriever<handle






    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=CurrentBlockPathRetriever()
        end
    end

    methods
        function currentBlockPath=retrieve(this,blockTypeEnum)
            currentBlockPath=[];




            selectedBlocks=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block','selected','on');

            gcbValid=FunctionApproximation.internal.Utils.isBlockPathValid(gcb);


            if gcbValid
                selectedBlocks=string(selectedBlocks);
                locationGCB=selectedBlocks==string(gcb);
                selectedBlocks(locationGCB)=[];
                selectedBlocks={selectedBlocks{:}};
                selectedBlocks=[{gcb},selectedBlocks];
            end



            for ii=1:numel(selectedBlocks)
                if FunctionApproximation.internal.Utils.getBlockType(selectedBlocks{ii})==blockTypeEnum
                    currentBlockPath=selectedBlocks{ii};
                    success=true;
                    if~isPathValidForEnum(this,blockTypeEnum,currentBlockPath)


                        success=false;
                    end

                    if success
                        currentBlockPath=selectedBlocks{ii};
                        break;
                    end
                end
            end
        end
    end

    methods(Access=private)
        function isValid=isPathValidForEnum(~,blockTypeEnum,currentBlockPath)
            switch blockTypeEnum
            case FunctionApproximation.internal.BlockType.LUT


                isValid=FunctionApproximation.internal.Utils.isLUTBlock(currentBlockPath);
            case FunctionApproximation.internal.BlockType.Math


                isValid=FunctionApproximation.internal.Utils.isMathFunctionBlock(currentBlockPath);
            otherwise

                isValid=true;
            end
        end
    end
end
