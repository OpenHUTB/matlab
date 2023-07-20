function result=feature_FunctionConnector()
    result=true;

    if slfeature('GeneralConnector')>0
        result=false;
    end
end