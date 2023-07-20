function launchBlockApp(block)







    type=serdes.internal.callbacks.getLibraryBlockType(block);

    switch type
    case 'CTLE'
        mws=get_param(bdroot(block),'ModelWorkspace');
        wsSymbolTime=mws.getVariable('SymbolTime');
        fitterButton(serdes.CTLE,block,wsSymbolTime.Value)
    end

