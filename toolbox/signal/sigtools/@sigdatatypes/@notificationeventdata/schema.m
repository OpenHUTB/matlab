function schema





    pk=findpackage('sigdatatypes');


    c=schema.class(pk,'notificationeventdata',pk.findclass('sigeventdata'));

    if isempty(findtype('sigdatatypesNotificationType'))
        schema.EnumType('sigdatatypesNotificationType',...
        {'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'});
    end


    schema.prop(c,'NotificationType','sigdatatypesNotificationType');


