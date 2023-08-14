function drawRTWCGBlock(this,slBlockName,hC)
    if isprop(hC,'blockTag')
        blkTag=hC.blockTag;
        if hC.SimulinkHandle<0
            BlockType=hC.getPropertyValueString('Type');
        else
            BlockType=get_param(hC.SimulinkHandle,'BlockType');
        end
    else
        BlockType=hC.getPropertyValueString('BlockType');
        blkTag=['built-in/',BlockType];
    end

    [name,slHandle]=addBlock(this,hC,blkTag,slBlockName);
    setProperties(this,hC,slHandle);

    if strcmp(BlockType,'SubSystem')
        hRef=hC.ReferenceNetwork;


        convert2VariantSystem(this,hC,name);
        drawNetwork(this,slBlockName,hRef,hC);
        setPorts(this,name,hRef,hC);




        if~isempty(hC.getPropertyValueString('ActiveVariant'))&&...
            strcmp(hC.getPropertyValueString('hasSFunction'),'false')
            set_param(slBlockName,'LabelModeActiveChoice','')
            set_param(slBlockName,'GeneratePreprocessorConditionals','on')
        end
    end
end

