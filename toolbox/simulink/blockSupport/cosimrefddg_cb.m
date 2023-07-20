function varargout=cosimrefddg_cb(src,action,varargin)


    if isnumeric(src)&&ishandle(src)
        h=get_param(src,'Object');
        blkH=src;
    else
        h=src.getBlock;
        blkH=h.Handle;
    end

    if strcmp(get_param(blkH,'BlockType'),'ObserverReference')
        openFcn='Simulink.observer.internal.openObserverMdlFromObsRefBlk';
        paramName='ObserverModelName';
        helpPath='observer_reference_block_ref';
    else
        openFcn='Simulink.injector.internal.openInjectorMdlFromInjRefBlk';
        paramName='InjectorModelName';
        helpPath='injector_reference_block_ref';
    end

    switch action
    case 'open'
        feval(openFcn,blkH);

    case 'postApply'
        dlg=varargin{1};
        newCtxMdlName=dlg.getWidgetValue(paramName);
        oldCtxMdlName=get_param(blkH,paramName);
        if~strcmp(oldCtxMdlName,newCtxMdlName)
            set_param(blkH,paramName,newCtxMdlName);
        end
        varargout{1}=true;
        varargout{2}='';

    case 'help'
        helpview([docroot,'/sltest/helptargets.map'],helpPath);
    end

end