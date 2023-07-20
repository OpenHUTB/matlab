function msOfficeApps(method)
    persistent wState wDocs xState xDocs;

    switch method
    case 'cache'
        [wState,wDocs]=rmiref.WordUtil.appState('get');
        [xState,xDocs]=rmiref.ExcelUtil.appState('get');
    case 'restore'
        rmiref.WordUtil.appState('restore',wState,wDocs);
        rmiref.ExcelUtil.appState('restore',xState,xDocs);
    otherwise
        error(message('Slvnv:rmi:informer:UnsupportedMethod',method,'populateInformerData:msOfficeApps()'));
    end
end
