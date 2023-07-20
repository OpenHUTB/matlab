
function[blockPath,portIndex]=elaborateContext(this)

    portH=this.Context{1}.portH;
    portIndex=get(portH,'PortNumber');
    blockPath=get_param(portH,'Parent');
end
