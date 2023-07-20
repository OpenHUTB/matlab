classdef LayoutStrategy<handle





    properties(Access=protected)
        ModelName;
        AddedCentralBlocks;
        AddedBlocks;
        ServerRunSSBlocks;
        IsUpdateMode;
        CentralBlockType;
    end

    methods(Abstract)
        setBlockPosition(this,blockPath);
        refresh(this);
    end

    methods
        function addedBlocks=getAddedBlocks(this)
            addedBlocks=[this.AddedCentralBlocks,this.AddedBlocks];
        end

        function addedCentralBlocks=getAddedCentralBlocks(this)
            addedCentralBlocks=this.AddedCentralBlocks;
        end

        function addServRunSSBlocks(this,blks)
            if~isempty(this.ServerRunSSBlocks)
                this.ServerRunSSBlocks=[this.ServerRunSSBlocks,blks];
            else
                if iscell(blks)
                    this.ServerRunSSBlocks=blks;
                else
                    this.ServerRunSSBlocks={blks};
                end
            end
        end

        function addBlocks(this,blks)
            blks=get_param(blks,'Handle');
            if iscell(blks)
                blks=[blks{:}];
            end
            if~isempty(this.AddedBlocks)
                this.AddedBlocks=[this.AddedBlocks,blks];
            else
                this.AddedBlocks=blks;
            end
        end

        function removeBlock(this,blk)
            if~isempty(this.AddedBlocks)
                index=find(arrayfun(@(x)strcmp(getfullname(x),blk),this.AddedBlocks,'UniformOutput',1));
                if~isempty(index)
                    this.AddedBlocks(index)=[];
                end
            end
        end
    end
end
