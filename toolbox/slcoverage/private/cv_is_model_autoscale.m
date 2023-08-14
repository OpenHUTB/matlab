function result=cv_is_model_autoscale(model)



    result=get_param(model,'CovAutoscale');
    result=strcmp(result,'on');
