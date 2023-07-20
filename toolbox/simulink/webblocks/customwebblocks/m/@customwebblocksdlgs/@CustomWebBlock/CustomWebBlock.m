function this=CustomWebBlock(block)
    this=customwebblocksdlgs.CustomWebBlock(block);
    this.init(block);
    switch get_param(block,'CustomType')
    case{'Circular Gauge','Horizontal Gauge','Vertical Gauge'}
        this.widgetType='gauge';
    case 'Lamp'
        this.widgetType='lampblock';
    end