function node=createTstoolNode(ts,h,varargin)






    nodeName=h.getTstoolNodeName(ts,'tsguis.simulinkTsArrayNode',varargin{:});
    if isempty(nodeName)
        node=[];
        return;
    end


    node=tsguis.simulinkTsArrayNode(nodeName,ts);



    tsguis.addTstoolChildrenNodes(ts,node)


    node.DataNameChangeListener=handle.listener(node.SimModelhandle,...
    node.SimModelhandle.findprop('Name'),'PropertyPostSet',...
    {@localUpdateNodeName,node});

    function localUpdateNodeName(es,ed,node)

        newName=node.SimModelhandle.Name;
        node.updateNodeNameCallback(newName);