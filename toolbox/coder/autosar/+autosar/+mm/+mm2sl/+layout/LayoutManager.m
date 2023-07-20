classdef LayoutManager<handle





    properties(Access=protected)
        LayoutStrategy;
    end

    methods(Abstract)
        addBlock(this,blockPath);
        refresh(this);
    end

    methods
        function addedBlocks=getAddedBlocks(this)
            addedBlocks=this.LayoutStrategy.getAddedBlocks();
        end

        function removeBlock(this,blockPath)
            this.LayoutStrategy.removeBlock(blockPath);
        end
    end
end
