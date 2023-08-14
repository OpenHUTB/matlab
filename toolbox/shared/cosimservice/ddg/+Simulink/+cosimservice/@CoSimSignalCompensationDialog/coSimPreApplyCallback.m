function[status,errmsg]=coSimPreApplyCallback(this,dlg)


    try
        dlg.getDialogSource.inputPortsSource.applyAllConfiguration;
    catch E


        throwAsCaller(E);
    end

    status=true;
    errmsg='';
end
