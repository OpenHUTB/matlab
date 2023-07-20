function this=ComboBox(block)

    this=hmiblockdlg.ComboBox(block);
    this.init(block);
    this.widgetType='combobox';
    this.propMap=containers.Map('keyType','int32','ValueType','any');
    modelName=get_param(bdroot(this.blockObj.Handle),'Name');
    initProps=utils.getDiscreteKnobInitialPropertiesStruct(modelName,this.widgetId,this.isLibWidget);
    for idx=1:length(initProps)
        this.propMap(idx)=initProps(idx);
    end
end
