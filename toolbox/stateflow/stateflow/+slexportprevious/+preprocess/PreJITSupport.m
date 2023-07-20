function PreJITSupport(obj)

    if isR2014bOrEarlier(obj.ver)


        obj.appendRule('<chart<zeroJitEmissions:remove>>');
        obj.appendRule('<machine<zeroJitEmissions:remove>>');


        machine=getStateflowMachine(obj);
        if isempty(machine)
            return;
        end

        currentRuntimeCheckVal=sf('get',machine.Id,'.debug.runTimeCheck');
        newRuntimeCheckVal=[currentRuntimeCheckVal(1),0,currentRuntimeCheckVal(2:end)];
        obj.appendRule(sprintf('<machine<debug<runTimeCheck:repval %s>>>',...
        mat2str(newRuntimeCheckVal)));
    end
