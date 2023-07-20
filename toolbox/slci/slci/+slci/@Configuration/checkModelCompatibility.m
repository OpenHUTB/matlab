function summary=checkModelCompatibility(aObj)




    profileCompat=slci.internal.Profiler('SLCI','Compatibility',...
    aObj.getModelName(),...
    aObj.getTargetName());



    TerminateOnIncompatibility=false;
    FatalIncompatibility=false;
    slciModel=slci.simulink.Model(aObj.getModelName());
    slciModel.setCheckAsRefModel(~aObj.getTopModel());
    slciModel.setInspectSharedUtils(slci.Configuration.getInspectSharedUtils);
    slciModel.AddConstraints();
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        Incompatibilities=slciModel.checkCompatibility;
        aObj.createReportFolder();
        aObj.setModelObj(slciModel);
    catch ME










        DAStudio.error('Slci:compatibility:checkFailure')
    end
    if isempty(Incompatibilities)
        Result=0;
    else
        Result=1;
    end
    if slcifeature('IgnoreFatalIncompatibilities')~=1


        if~isempty(Incompatibilities)&&...
            aObj.getTerminateOnIncompatibility()
            Result=1;
            TerminateOnIncompatibility=true;
        else

            for incompatIdx=1:numel(Incompatibilities)
                if Incompatibilities(incompatIdx).getFatal()
                    Result=1;
                    FatalIncompatibility=true;
                end
            end
        end
    end

    summary=aObj.CollateResults(...
    false,Result,Incompatibilities,FatalIncompatibility,...
    TerminateOnIncompatibility);

    profileCompat.stop();

end


