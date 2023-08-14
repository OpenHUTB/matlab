function hdlresetgcb(startNodeName)




    if isempty(startNodeName)
        return;
    end


    mdlName=strtok(startNodeName,'/');
    set_param(0,'CurrentSystem',mdlName);


    parent=get_param(startNodeName,'parent');
    if~isempty(parent)
        set_param(0,'CurrentSystem',parent);
        set_param(parent,'CurrentBlock',get_param(startNodeName,'handle'));
    end
end
