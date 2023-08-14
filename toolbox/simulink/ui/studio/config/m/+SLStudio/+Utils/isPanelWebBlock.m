function result=isPanelWebBlock(cbinfoOrBlock)
    result=false;
    block=[];
    if isa(cbinfoOrBlock,'SLM3I.CallbackInfo')
        block=SLStudio.Utils.getSingleSelectedBlock(cbinfoOrBlock);
    elseif isa(cbinfoOrBlock,'SLM3I.Block')
        block=cbinfoOrBlock;
    end
    if~isempty(block)
        result=SLStudio.Utils.objectIsValidBlock(block)&&strcmp(block.type,'PanelWebBlock');
    end
end