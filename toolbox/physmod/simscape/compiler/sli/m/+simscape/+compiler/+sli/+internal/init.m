function init(model,mp)







    isSupported=lCheckModelRef(model);
    if~isSupported
        pm_error('physmod:simscape:compiler:sli:init:ModelRefTargetNotSupported');
    end
end

function isSupported=lCheckModelRef(model)

    mdlRefTarget=get_param(model,'ModelReferenceTargetType');
    switch upper(mdlRefTarget)
    case 'NONE'
        isSupported=true;
    case 'SIM'

        isSupported=lSimTargetSupported(model);
    case 'RTW'
        isSupported=true;
    otherwise
        isSupported=false;
    end
end

function isSupported=lSimTargetSupported(model)


    mdlRefSimTarget=get_param(model,'ModelReferenceSimTargetType');
    switch upper(mdlRefSimTarget)
    case 'NONE'
        isSupported=true;
    case 'NORMAL'
        isSupported=true;
    case 'ACCELERATOR'
        isSupported=true;
    otherwise
        isSupported=false;
    end
end



