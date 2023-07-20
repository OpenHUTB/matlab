function varargout=imageddg_cb(dlg,action,varargin)



    if~isempty(dlg)
        h=dlg.getDialogSource;
    end

    switch action

    case 'doApply'
        h.fixedHeight=dlg.getWidgetValue('fixedSize');
        h.fixedWidth=dlg.getWidgetValue('fixedSize');
    end

    varargout{1}=1;
    varargout{2}='';
