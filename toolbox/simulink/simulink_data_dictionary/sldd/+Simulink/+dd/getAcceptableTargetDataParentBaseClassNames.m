function parentClassNames=getAcceptableTargetDataParentBaseClassNames










    persistent acceptableTargetDataParentBaseClassNames;

    if isempty(acceptableTargetDataParentBaseClassNames)
        acceptableTargetDataParentBaseClassNames={
        'Simulink.Parameter';
        'Simulink.Signal';
        'Simulink.LookupTable';
        'Simulink.Breakpoint';
        'Simulink.AliasType';
        'Simulink.NumericType';
        'Simulink.Bus';
        'Simulink.ConnectionBus';
'Simulink.DualScaledParameter'
        };
    end
    parentClassNames=acceptableTargetDataParentBaseClassNames;
end

