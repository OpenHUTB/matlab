function Parms=autoblksgetmaskparms(Block,ParmNames,Assign)

    MaskObject=get_param(Block,'MaskObject');
    MaskVarNames={MaskObject.getWorkspaceVariables.Name};
    MaskVarValues={MaskObject.getWorkspaceVariables.Value};
    for idx=1:length(ParmNames)
        [~,j]=intersect(MaskVarNames,ParmNames{idx});
        Value=MaskVarValues{j};

        if isa(Value,'Simulink.Parameter')
            Parms{idx}=Value.Value;
        else
            Parms{idx}=Value;
        end

        if Assign
            assignin('caller',ParmNames{idx},Parms{idx});
        end

    end

end
