function result=feature_ScheduleConnector()
    result=true;

    if slfeature('GeneralConnector')>0
        result=false;
    end
end