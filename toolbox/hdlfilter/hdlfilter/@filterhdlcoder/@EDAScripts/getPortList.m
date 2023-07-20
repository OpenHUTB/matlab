function[entityPortList,entityRefPortList]=getPortList(this)





    entityPortList=hdlgetparameter('lasttoplevelportnames');

    entityRefPortList=entityPortList;
    for ii=1:length(entityPortList)
        if this.hasRefSignal(entityPortList{ii})
            entityRefPortList{ii}=entityPortList{ii};
        else
            entityRefPortList{ii}='';
        end
    end
