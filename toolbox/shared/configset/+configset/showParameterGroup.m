function showParameterGroup(csOrModel,groupName,~)





















    narginchk(2,3);

    if~(ischar(groupName)||iscellstr(groupName)||isstring(groupName))
        error(message('configset:util:InputMustBeStringOrCellstr',2,mfilename));
    end

    if isa(csOrModel,'Simulink.ConfigSetRoot')
        cs=csOrModel;
    else
        cs=getActiveConfigSet(csOrModel);
    end

    if isa(cs,'Simulink.ConfigSetRef')&&slfeature('ConfigSetRefOverride')<2



        cs.view;


        web=configset.internal.util.getHTMLView(cs);

        if~isempty(web)
            web.showGroup(groupName);
        end
    elseif isa(cs,'Simulink.ConfigSetRoot')

        dlg=cs.getDialogHandle;
        if isempty(dlg)


            action.showGroup=configset.internal.util.convertShowGroupInput(groupName);
            cs.view(action);
        else
            web=dlg.getDialogSource;
            web.showGroup(groupName);

            dlg.show;
        end
    end
