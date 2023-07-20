function this=AttributeBlockDialog(block,varargin)




    this=ssm.AttributeBlockDialog(block);

    blockType=get_param(block,'BlockType');
    switch blockType
    case 'DataTable'
        this.Impl=ssm.mask.DataTable(block,this);
    case 'DataTableReader'
        this.Impl=ssm.mask.DataTableReader(block,this);
    case 'DataTableWriter'
        this.Impl=ssm.mask.DataTableWriter(block,this);
    otherwise
        this.Impl=[];
    end



end

