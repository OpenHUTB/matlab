classdef LayoutLayers




    properties(SetAccess=private)
GraphLayers
NonGraphBlocks
    end


    methods
        function this=LayoutLayers(layers,nonGraphBlocks)
            this.GraphLayers=layers;
            this.NonGraphBlocks=nonGraphBlocks;
        end
    end

end
