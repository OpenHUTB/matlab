function StudioAdapter(obj)



    if isR2021aOrEarlier(obj.ver)

        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end

        emlBlocks=find(machineH,'-isa','Stateflow.EMChart');
        emlBlocks=[emlBlocks;find(machineH,'-isa','Stateflow.EMFunction')];
        for i=1:numel(emlBlocks)
            sid=StateflowDI.SFDomain.getSIDForObject(emlBlocks(i).Id);
            obj.appendRule(['<EditorsInfo<Object<LoadSaveID|"',sid,'">:remove>>']);
        end
    end

end
