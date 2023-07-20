
function enforceNone=enforceNoneInstructionSet(cs)
    enforceNone=false;

    if isempty(cs)
        return;
    elseif~isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end

    stf=get_param(config,'SystemTargetFile');
    isSLRT=strcmp(stf,'slrt.tlc')||strcmp(stf,'slrealtime.tlc');
    gpu=~strcmpi(get_param(config,'GenerateGPUCode'),'None');
    if isSLRT||gpu
        enforceNone=true;
    end
end
