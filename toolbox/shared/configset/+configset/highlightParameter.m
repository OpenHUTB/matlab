function highlightParameter(csOrModel,param_name,varargin)


















    narginchk(2,5);

    if~(ischar(param_name)||iscellstr(param_name)||isstring(param_name))
        error(message('Simulink:Commands:InputMustBeStringOrCellstr',2,'highlightParameter'));
    end

    if isa(csOrModel,'Simulink.ConfigSetRoot')
        cs=csOrModel;
    else
        cs=getActiveConfigSet(csOrModel);
    end

    if nargin<3
        reason='default';
    else
        reason=varargin{1};
    end

    if isa(cs,'Simulink.ConfigSetRef')

        cs.view;


        web=configset.internal.util.getHTMLView(cs);
        if~isempty(web)
            web.highlight(param_name,reason);
        end
    elseif isa(cs,'Simulink.ConfigSet')

        dlg=cs.getDialogHandle;
        if isempty(dlg)


            action.highlight=configset.internal.util.convertHighlightInput(param_name,cs);
            action.highlightReason=reason;
            cs.view(action);
        else
            web=dlg.getDialogSource;
            web.highlight(param_name,reason);

            dlg.show;
        end
    end



