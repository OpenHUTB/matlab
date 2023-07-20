function isSLFcn=isSimulinkFunction(blk)




    isSLFcn=false;
    if(strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
        strcmp(get_param(blk,'IsSimulinkFunction'),'on'))
        isSLFcn=true;
    end
end
