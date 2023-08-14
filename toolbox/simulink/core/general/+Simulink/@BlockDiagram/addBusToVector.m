function[dstBlocks,busToVectorBlocks,ignoredBlocks]=addBusToVector(varargin)

















































































































    switch nargout
    case 0
        slprivate('addBDBusToVectorImpl',varargin{:});
    case 1
        dstBlocks=slprivate('addBDBusToVectorImpl',varargin{:});
    case 2
        [dstBlocks,busToVectorBlocks]=slprivate('addBDBusToVectorImpl',varargin{:});
    case 3
        [dstBlocks,busToVectorBlocks,ignoredBlocks]=slprivate('addBDBusToVectorImpl',varargin{:});
    end

end

