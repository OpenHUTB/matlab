function bReadonly=isHierarchyReadonly(h)




    cls=class(h);
    switch cls
    case{'SigLogSelector.BdNode','SigLogSelector.MdlRefNode'}
        mi=h.getModelLoggingInfo();
        if isempty(mi)
            bReadonly=true;
        else
            bReadonly=...
            (mi.OverrideMode==Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel);
        end

    otherwise
        bReadonly=h.logAsSpecified;
    end

end
