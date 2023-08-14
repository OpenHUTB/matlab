function this=DDGDialog(block,varargin)




    this=slde.DDGDialog(block);
    blkType=get_param(block,'BlockType');

    switch blkType
    case 'EventSignalLatch'
        this.Impl=slde.ddg.EventSignalLatch(block,this);
    otherwise
        assert(false);
    end



