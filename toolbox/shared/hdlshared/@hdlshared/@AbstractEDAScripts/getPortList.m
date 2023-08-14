function[entityPortList,entityRefPortList]=getPortList(this)


    entityPortList=hdlentityportnames;
    entityRefPortList=entityPortList;
    for ii=1:length(entityPortList)
        if~this.hasRefSignal(entityPortList{ii})
            entityRefPortList{ii}='';
        end
    end