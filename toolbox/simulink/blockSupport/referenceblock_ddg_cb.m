function varargout=referenceblock_ddg_cb(action,varargin)





    dialogH=varargin{1};
    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end

    switch action
    case 'doPreApply'
        [~,~]=source.preApplyCallback(dialogH);
        [~,~]=i_doPreApply(dialogH,block);


        dialogH.refresh;
        dialogH.resetSize(1);

        varargout{1}=true;
        varargout{2}='';
    otherwise
        return;
    end
end


function[success,errmsg]=i_doPreApply(H,block)


    success=true;
    errmsg='';
    blockH=block.Handle;

    val=H.getWidgetValue('SourceBlock');
    if~isempty(val)
        try
            set_param(blockH,'SourceBlock',val);
        catch E
            success=false;
            errmsg=E.message;
        end
    end
end