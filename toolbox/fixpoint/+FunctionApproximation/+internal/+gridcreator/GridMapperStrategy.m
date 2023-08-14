classdef GridMapperStrategy<handle







    properties(SetAccess=protected,Hidden)
        GridMap(2,:)
    end

    methods(Abstract)
        mapGrid(this,keyGrid,valueGrid)
        indices=getIndices(this,keypair)
    end

    methods(Hidden)
        function setGridMap(this,gridMap)
            this.GridMap=gridMap;
        end

        function indices=getKeyGridIndicesWithMapping(this)
            indices=find(this.GridMap(1,:)>0);
        end
    end
end