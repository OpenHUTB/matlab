function nodes=getNodes(target,list,classkey)










    assert(any(strcmp(list,{'active','inactive'})),['Invalid argument to ',mfilename]);

    switch list
    case 'active'
        head=target.activeList;
    case 'inactive'
        head=target.inactiveList;
    end

    if nargin==2
        nodes=head.find('-class','RTWConfiguration.Node');
    else
        nodes=head.find(...
        '-class','RTWConfiguration.Node',...
        'classkey',classkey);

    end

