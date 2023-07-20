function RequirementsTables(obj)





    machineH=getStateflowMachine(obj);
    if isempty(machineH)
        return;
    end

    if isR2021bOrEarlier(obj.ver)
        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            if~ishandle(ch)

                continue
            end
            if Stateflow.ReqTable.internal.isRequirementsTable(ch.Id)
                obj.reportWarning('Slvnv:reqmgt:specBlock:SaveToPreviousVersion',ch.Path);
                blkH=sfprivate('chart2block',ch.Id);
                obj.replaceWithEmptySubsystem(blkH,'Requirements Table');
            end
        end
    end

end
