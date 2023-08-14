function OKCallback(hObj,hDlg)





    debugging=get(hObj,'myDebuggingCC');
    allUnitSysFlag=get(hObj,'allUnitSysFlag');
    selectedUnitSys=get(hObj,'selectedUnitSys');


    if strcmp(allUnitSysFlag,'on')
        unitSystemStr='all';
    else
        unitSystemStr=strjoin(selectedUnitSys,',');

    end
    old_unitsys=get_param(debugging,'AllowedUnitSystems');
    set_param(debugging,'AllowedUnitSystems',unitSystemStr);

    dlg=get(hObj,'ParentDlg');
    if~isempty(dlg)
        new_unitsys=debugging.get_param('AllowedUnitSystems');
        if~isequal(old_unitsys,new_unitsys)
            dlg.getDialogSource.enableApplyButton(true);

            if slfeature('ConfigsetDDUX')==1
                if(isa(dlg,'DAStudio.Dialog'))
                    htmlView=dlg.getDialogSource;
                    data=struct;
                    data.paramName='AllowedUnitSystems';
                    data.paramValue=new_unitsys;
                    data.widgetType='ddg';
                    htmlView.publish('sendToDDUX',data);
                end
            end
        end
        dlg.refresh;
    end

    delete(hDlg);
