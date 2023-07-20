function node=createNode(target,list,data,resources,sourceLibrary)














    node=RTWConfiguration.Node;











    node.sourceLibrary=sourceLibrary;

    assert(any(strcmp(list,{'active','inactive'})),['Invalid argument to ',mfilename]);

    switch list
    case 'active'
        target.connectNodeToActiveList(node);
    case 'inactive'
        target.connectNodeToInactiveList(node);
    end

    node.data=data;
    node.resources=resources;


