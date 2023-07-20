function ParamWidgetCallback(this,dlg,paramName,refreshFlag,varargin)




    block=this.getBlock;

    switch block.IntrinsicDialogParameters.(paramName).Type
    case 'boolean'
        if varargin{1}
            this.DialogData.(paramName)='on';
        else
            this.DialogData.(paramName)='off';
        end
    case 'enum'
        entries=block.getPropAllowedValues(paramName)';
        this.DialogData.(paramName)=entries{varargin{1}+1};
    case 'string'
        this.DialogData.(paramName)=varargin{1};
    end

    if refreshFlag
        dlg.refresh;
    end

end
