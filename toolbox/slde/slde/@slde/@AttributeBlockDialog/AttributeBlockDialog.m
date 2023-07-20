function this=AttributeBlockDialog(block,varargin)




    this=slde.AttributeBlockDialog(block);

    blockType=get_param(block,'BlockType');
    switch blockType
    case 'AttributeReader'
        this.Impl=slde.ddg.AttributeReader(block,this);
    case 'AttributeWriter'
        this.Impl=slde.ddg.AttributeWriter(block,this);
    case 'EntityGenerator'
        this.Impl=slde.ddg.EntityGenerator(block,this);
    case 'Queue'
        this.Impl=slde.ddg.EntityQueue(block,this);
    case 'EntityServer'
        this.Impl=slde.ddg.EntityServer(block,this);
    case 'EntityTerminator'
        this.Impl=slde.ddg.EntityTerminator(block,this);
    case 'EntityResourceAcquirer'
        this.Impl=slde.ddg.ResourceAcquire(block,this);
    case 'EntityResourceReleaser'
        this.Impl=slde.ddg.ResourceRelease(block,this);
    case 'CompositeEntityCreator'
        this.Impl=slde.ddg.CompositeEntityCreator(block,this);
    case 'EntityBatchCreator'
        this.Impl=slde.ddg.EntityBatcher(block,this);
    case 'EntityBatchSplitter'
        this.Impl=slde.ddg.EntityUnbatcher(block,this);
    case 'EntityOutputSwitch'
        this.Impl=slde.ddg.EntityOutputSwitch(block,this);
    case 'EntityStore'
        this.Impl=slde.ddg.EntityStore(block,this);
    case 'FindEntity'
        this.Impl=slde.ddg.FindEntity(block,this);
    case 'DataTable'
        this.Impl=slde.ddg.ssm.DataTable(block,this);
    case 'DataTableReader'
        this.Impl=slde.ddg.ssm.DataTableReader(block,this);
    case 'DataTableWriter'
        this.Impl=slde.ddg.ssm.DataTableWriter(block,this);
    otherwise
        this.Impl=[];
    end



end

