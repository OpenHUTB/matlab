classdef ApproximationBlockInfo







    properties(SetAccess=private,Hidden)

InternalTag
    end

    properties(Dependent)

BlockHandle


BlockPath


BlockSID


MaskObject
    end

    methods
        function this=ApproximationBlockInfo(variantSystemTag)
            this.InternalTag=variantSystemTag;
        end

        function blockHandle=get.BlockHandle(this)
            adapter=FunctionApproximation.internal.approximationblock.TagToBlockAdapter();
            blockHandle=adapter.getSubSystemHandle(this.InternalTag);
        end

        function sid=get.BlockSID(this)
            sid=Simulink.ID.getSID(this.BlockHandle);
        end

        function blockPath=get.BlockPath(this)
            blockPath=Simulink.ID.getFullName(this.BlockSID);
        end

        function maskObject=get.MaskObject(this)
            maskObject=Simulink.Mask.get(this.BlockHandle);
        end
    end
end
