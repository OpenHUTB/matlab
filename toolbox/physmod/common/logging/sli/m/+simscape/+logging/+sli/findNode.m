function blockNode=findNode(n,block)




    newName='simscape.logging.findNode';
    oldName='simscape.logging.sli.findNode';

    pm_warning('physmod:common:logging:sli:kernel:Deprecated',...
    oldName,newName);

    blockNode=simscape.logging.findNode(n,block);
