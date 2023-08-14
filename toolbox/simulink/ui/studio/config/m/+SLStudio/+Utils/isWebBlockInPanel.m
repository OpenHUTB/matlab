function result=isWebBlockInPanel(cbinfo)
    result=false;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if~isempty(block)&&block.isWebBlock()
        parentHandle=block.container.handle;
        result=strcmp(get_param(parentHandle,'Type'),'block')&&...
        strcmp(get_param(parentHandle,'BlockType'),'SubSystem')&&...
        strcmp(get_param(parentHandle,'IsWebBlockPanel'),'on');
    end
end