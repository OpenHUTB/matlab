function funcSet=uBlock2Link(h,curBadBlock,refstring,varargin)








    funcSet={'ModelUpdater.block2Link',curBadBlock,refstring,ModelUpdater.tmpLibName};
    if doUpdate(h)
        ModelUpdater.block2Link(curBadBlock,refstring,h.TempName,varargin{:});
    end

end

