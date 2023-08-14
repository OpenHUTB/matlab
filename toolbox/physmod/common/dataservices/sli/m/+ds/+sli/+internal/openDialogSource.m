
function status=openDialogSource(sid)




    status='';
    if Simulink.ID.isValid(sid)
        if isempty(get_param(sid,'OpenFcn'))


            open_system(Simulink.ID.getHandle(sid),'mask');
        else
            open_system(Simulink.ID.getHandle(sid));
        end
    else
        status=message('physmod:common:dataservices:core:sources:SourceNotFound').getString;
    end

end
