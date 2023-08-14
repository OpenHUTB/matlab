









function[isIndirect,workspace]=isIndirectUser(block)
    isIndirect=false;
    workspace=[];

    blockH=get_param(block,'handle');
    if isValidSlObject(slroot,blockH)
        type=get_param(blockH,"Type");
        if strcmp(type,"block")


            blockType=get_param(blockH,"BlockType");
            if strcmp(blockType,"SubSystem")&&~isempty(Simulink.Mask.get(blockH))
                isIndirect=true;
                workspace='mask workspace';
            elseif strcmp(blockType,'ModelReference')
                isIndirect=true;
                workspace='model workspace';
            end
        end
    end
end
