

function result=isWebBlock(blockHandle)




    result=false;
    conditionA=strcmp(get_param(blockHandle,'BlockType'),'SubSystem')&&...
    strcmp(get_param(blockHandle,'IsWebBlock'),'on');

    conditionB=strcmp(get_param(blockHandle,'isCoreWebBlock'),'on');


    if(conditionA||conditionB)
        result=true;
    end
end