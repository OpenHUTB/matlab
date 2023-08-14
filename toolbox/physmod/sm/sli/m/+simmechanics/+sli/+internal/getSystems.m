function[systems,compErrs,hasMultibody]=getSystems(slModel)











    systems=[];
    compErrs=[];
    hasMultibody=false;

    try
        vParam=...
        pm_message('sm:sli:configParameters:explorer:openEditorOnUpdate:ParamName');
        vParamVal=get_param(slModel,vParam);
        try
            dFlag=get_param(slModel,'Dirty');
            c=onCleanup(@()set_param(slModel,vParam,vParamVal,'Dirty',dFlag));

            set_param(slModel,vParam,'off');
            set_param(slModel,'Dirty',dFlag);
            set_param(slModel,'SimulationCommand','update');
        catch excpB
            compErrs=excpB;
            return;
        end
    catch excpA
        hasMultibody=false;
        return;
    end


    slModelName=get_param(slModel,'Name');
    slModelId=sm.mli.internal.MlId(slModelName);
    try
        systems=sm.sli.internal.getSystems_implementation(slModelId);
        hasMultibody=true;
    catch excp
        if strcmp(excp.identifier,'mech2:sli:import:mli:ModelNotFound')
            hasMultibody=false;
            return;
        end
        rethrow(excp);
    end

    if length(systems)>1
        for idx=1:length(systems)
            systems(idx).setName([slModelName,' - System',num2str(idx)]);
        end
    else
        systems.setName(slModelName);
    end
