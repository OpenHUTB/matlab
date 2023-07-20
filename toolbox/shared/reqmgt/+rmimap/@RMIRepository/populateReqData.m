function reqStruct=populateReqData(graphLink,reqStruct)

    if nargin<2
        reqStruct=rmi.createEmptyReqs(1);
    end

    graphNode=graphLink.dependeeNode;

    if isa(graphNode,'rmidd.Root')
        reqStruct.doc=graphNode.url;
        reqStruct.reqsys=graphNode.getProperty('source');
    else
        reqStruct.doc=graphNode.root.url;
        reqStruct.reqsys=graphNode.root.getProperty('source');
    end
    if~isempty(strfind(reqStruct.doc,'__UNSPECIFIED__'))
        reqStruct.doc='';
    end
    reqStruct.id=graphNode.id;

    reqStruct.linked=~strcmp(graphLink.getProperty('linked'),'0');
    reqStruct.description=graphLink.getProperty('description');
    reqStruct.keywords=graphLink.getProperty('keywords');
end
