function[isValid,nodePath]=findPath(node,block)




    newName='simscape.logging.findPath';
    oldName='simscape.logging.sli.findPath';

    pm_warning('physmod:common:logging:sli:kernel:Deprecated',...
    oldName,newName);

    [isValid,nodePath]=simscape.logging.findPath(node,block);
