
function deleteVariantSourceSinkPort(blockH,portNum)



















    bType=get_param(blockH,'BlockType');
    isVariantSource=strcmp(bType,'VariantSource');
    isVariantSink=strcmp(bType,'VariantSink');
    block=getfullname(blockH);


    calledFromReducer=false;


    try
        if isVariantSource
            Simulink.variant.utils.rewireVariantSource(block,portNum,calledFromReducer);
        elseif isVariantSink
            Simulink.variant.utils.rewireVariantSink(block,portNum,calledFromReducer);
        end
    catch me
        throwAsCaller(me);
    end
end