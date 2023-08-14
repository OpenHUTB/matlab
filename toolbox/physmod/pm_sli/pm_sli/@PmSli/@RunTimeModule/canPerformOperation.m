function canDoIt=canPerformOperation(this,hBlock,event,varargin)







    canDoIt=true;


    if isempty(hBlock)
        return;
    end

    if isa(hBlock,'double')||isa(hBlock,'char')
        hBlock=get_param(hBlock,'Object');
    end

    if pm.simscape.internal.isSimscapeComponentDependent(hBlock)
        return
    end

    switch event
    case 'BLK_POSTLOAD'
        this.postLoadBlock(hBlock);
    case 'BLK_POSTCOPY'
        if lPerformCallback(hBlock)
            this.postCopyBlock(hBlock);
        end
    case 'BLK_PRECOPY'
        if lPerformCallback(hBlock)
            this.preCopyBlock(hBlock);
        end
    case 'BLK_POSTUNDELETE'

    case 'BLK_PREDELETE'
        if lPerformCallback(hBlock)
            this.preDeleteBlock(hBlock);
        end
    case 'BLK_POSTDELETE'

    case 'BLK_OPENDLG'
        this.prepareToOpenDialog(hBlock);
    case 'BLK_PRESAVE'
        this.preSaveBlock(hBlock);
    case 'BLK_POSTSAVE'
        this.postSaveBlock(hBlock);
    case 'BLK_PRECOMPILE'
        this.preCompileBlock(hBlock);
    case 'DOM_INIT'
    case 'CCC_ACTIVATE'
        this.activateConfigSet(hBlock);
    case 'CCC_DEACTIVATE'
        this.deactivateConfigSet(hBlock);
    case 'SLM_SELECTMODE'
        this.setModelEditingMode_simulinkMenu(hBlock,varargin{:});
    case 'MODEL_CLOSE'
        this.modelCloseBlock(hBlock);

    otherwise

        configData=RunTimeModule_config;
        pm_error(configData.Error.UnknownBlockCallback_msg);

    end

end

function status=lPerformCallback(hBlock)








    try





        parentBlock=get_param(hBlock.Parent,'Object');



        linkStatus=pmsl_linkstatus(parentBlock);
        status=~(strcmp(linkStatus,'implicit')||strcmp(linkStatus,'resolved'));
    catch exception %#ok
        status=true;
    end


end


