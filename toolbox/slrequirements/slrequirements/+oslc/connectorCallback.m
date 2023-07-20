function varargout=connectorCallback(method,varargin)

    switch method

    case 'home'
        oslc.dumpCatalogInfo();

    case 'list'

        projectName=varargin{1};
        oslc.dumpReqInfo(projectName);

    case 'link'

        createLink(varargin{:});

    case 'select'
        oslc.selection(varargin{:});

    case 'current'
        [varargout{1},varargout{2}]=oslc.selection();

    case 'clear'
        oslc.selection('','');

    otherwise
        error('Invalid method in connectorCallback(): %s',method);
    end

end

function createLink(id,label)
    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_oslc';
    reqItem=oslc.getReqItem(id);
    req.doc=[reqItem.queryBase,' (',reqItem.projectName,')'];
    req.id=[reqItem.resource,' (',reqItem.identifier,')'];
    req.description=label;
    [target,isSf]=rmisl.getSelection();%#ok<ASGLU>
    rmi.catReqs(target,req);
end


