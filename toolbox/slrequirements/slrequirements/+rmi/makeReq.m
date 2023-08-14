function req=makeReq(linkTarget,refObj,srcType)

    if nargin<3
        srcType=rmiut.resolveType(linkTarget);
    end

    switch srcType

    case 'data'
        req=rmide.makeReq(linkTarget,refObj);

    case 'matlab'
        [srcKey,remainder]=strtok(linkTarget,'|');
        req=rmiml.makeReq(srcKey,remainder(2:end));

    case 'testmgr'
        req=rmitm.makeReq(linkTarget,refObj);

    case 'slreq'
        req=slreq.internal.makeReq(linkTarget,refObj);

    case 'simulink'
        if~ischar(linkTarget)
            [source,canceled]=rmi.canlink2way(linkTarget);
            if canceled||length(source)<length(linkTarget)

                req=[];
                return;
            end
        end
        req=rmisl.makeReq(linkTarget);

    case 'fault'
        req=rmifa.makeReq(linkTarget);
    case 'safetymanager'
        req=rmism.getRmiStruct(linkTarget,false);
    otherwise
        req=rmi.createEmptyReqs(1);
        req.description=['Type "',srcType,'" NOT YET SUPPORTED'];
    end
end

