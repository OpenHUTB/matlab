

function[isManualIVBlock,blockType]=isManualIVBlock(blockPathInModel)
    blockType=[];
    maskObject=get_param(blockPathInModel,'MaskObject');
    isManualIVBlock=~isempty(maskObject)&&any(strcmp(maskObject.Type,...
    {'ManualVariantSource','ManualVariantSink'}));
    if isManualIVBlock
        referenceBlock=get_param(blockPathInModel,'ReferenceBlock');
        prefixStr=['simulink/Signal',newline,'Routing/Manual',newline];
        if any(strcmp(referenceBlock,{[prefixStr,'Variant Sink'],[prefixStr,'Variant Source']}))
            blockType=maskObject.Type;
        else
            isManualIVBlock=false;
        end
    end
end