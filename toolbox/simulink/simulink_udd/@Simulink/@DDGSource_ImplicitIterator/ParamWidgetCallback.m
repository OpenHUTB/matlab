function ParamWidgetCallback(this,dlg,paramName,refreshFlag,varargin)




    block=this.getBlock;

    if isequal(paramName,'NeedActiveIterationSignal')
        if varargin{1}
            this.DialogData.(paramName)='on';
        else
            this.DialogData.(paramName)='off';
        end
    elseif isequal(paramName,'StateReset')
        entries=block.getPropAllowedValues(paramName)';
        this.DialogData.(paramName)=entries{varargin{1}+1};
    else
        switch block.IntrinsicDialogParameters.(paramName).Type
        case 'enum'
            entries=block.getPropAllowedValues(paramName)';
            this.DialogData.(paramName)=entries{varargin{1}+1};
        case 'string'
            this.DialogData.(paramName)=varargin{1};
        case 'boolean'
            if varargin{1}
                this.DialogData.(paramName)='on';
            else
                this.DialogData.(paramName)='off';
            end
        end
    end

    if refreshFlag
        dlg.refresh;
    end

end
