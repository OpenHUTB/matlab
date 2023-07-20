function status=openSource(sid)




    status='';
    if Simulink.ID.isValid(sid)
        pm.sli.highlightSystem(sid);
    else
        status=message('physmod:common:dataservices:core:sources:SourceNotFound').getString;
    end

end
