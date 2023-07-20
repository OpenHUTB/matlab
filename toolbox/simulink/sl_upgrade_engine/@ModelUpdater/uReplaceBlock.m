function funcSet=uReplaceBlock(h,oldBlock,newBlock,varargin)








    funcSet={'ModelUpdater.replaceBlock',oldBlock,newBlock,varargin{:}};%#ok<CCAT>

    if(doUpdate(h))
        ModelUpdater.replaceBlock(oldBlock,newBlock,varargin{:});
    end

end


