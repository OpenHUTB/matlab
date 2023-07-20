function bool=isReferencedModel(h,modelname,TargetType)




    narginchk(3,3);

    if~any(strcmp(TargetType,{'SIM','RTW','NONE'}))
        error(message('ERRORHANDLER:utils:InvalidTargetType'));
    end

    modelRefTargetType=get_param(modelname,'ModelReferenceTargetType');
    if strcmp(modelRefTargetType,TargetType)
        bool=true;
    else
        bool=false;
    end
