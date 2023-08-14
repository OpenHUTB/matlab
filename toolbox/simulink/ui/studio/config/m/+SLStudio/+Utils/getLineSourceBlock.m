function block=getLineSourceBlock(line)




    port=SLStudio.Utils.getLineSourcePort(line);
    block={};
    if~isempty(port)
        block=port.container;
    end
end
