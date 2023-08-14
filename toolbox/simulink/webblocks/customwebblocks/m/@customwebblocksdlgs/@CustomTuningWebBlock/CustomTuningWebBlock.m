function this=CustomTuningWebBlock(block)
    this=customwebblocksdlgs.CustomTuningWebBlock(block);
    this.init(block);
    switch get_param(block,'CustomType')
    case 'Knob'
        this.widgetType='knob';
    case{'Horizontal Slider','Vertical Slider'}
        this.widgetType='slider';
    case 'Switch'
        this.widgetType='switch';
    case 'Push Button'
        this.widgetType='pushbutton';
    end
    this.editingFcn=0;
    this.propMap=containers.Map('keyType','int32','ValueType','any');