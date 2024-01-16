function convert2VariantSystem(this,hC,blockNameWithFullPath)
    vc=hC.getPropertyValueString('ActiveVariant');
    if isempty(vc)
        return;
    end

    addBlock(this,[],'built-in/Inport',[blockNameWithFullPath,'/Variant_In1']);
    addBlock(this,[],'built-in/Outport',[blockNameWithFullPath,'/Variant_Out1']);
    add_line(blockNameWithFullPath,'Variant_In1/1','Variant_Out1/1');


    Simulink.VariantManager.convertToVariant(get_param(blockNameWithFullPath,'Handle'));
end