

function this=RadioButtonGroup(block)
    this=hmiblockdlg.RadioButtonGroup(block);
    this.init(block);
    this.widgetType='radiobuttongroup';
    modelName=get_param(bdroot(block),'Name');
    this.propMap=containers.Map('keyType','int32','ValueType','any');
    initProps=utils.getDiscreteKnobInitialPropertiesStruct(modelName,this.widgetId,this.isLibWidget);
    for idx=1:length(initProps)
        this.propMap(idx)=initProps(idx);
    end
end