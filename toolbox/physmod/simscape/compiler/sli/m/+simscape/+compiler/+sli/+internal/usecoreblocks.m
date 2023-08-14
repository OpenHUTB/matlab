function useCoreBlocks=usecoreblocks(v)



    persistent pCoreBlocks;

    if isempty(pCoreBlocks)
        pCoreBlocks=true;
    end

    if nargin==1
        pCoreBlocks=v;
    end

    useCoreBlocks=pCoreBlocks;


end