function IrqPriorityList=rearrangeIrqPriority(ModelName,IrqPriorityList)











    SimulinkTaskPriority=getSimulinkTaskPriority(IrqPriorityList.IrqPriorityList);


    SimulinkTaskPriority=mapSimulinkTaskPriorityToIrqPriority(ModelName,SimulinkTaskPriority);


    IrqPriorityList.IrqPriorityList=assignProcessorPriorityToTasks(IrqPriorityList.IrqPriorityList,SimulinkTaskPriority);
end




















function SimulinkTaskPriority=getSimulinkTaskPriority(IrqPriorityList)
    if isstruct(IrqPriorityList)
        SimulinkTaskPriority=IrqPriorityList.SimulinkTaskPriority;
    else
        SimulinkTaskPriority=cellfun(@(x)x.SimulinkTaskPriority,IrqPriorityList);
    end
end



function SimulinkTaskPriority=mapSimulinkTaskPriorityToIrqPriority(ModelName,SimulinkTaskPriority)
    UniqueSimulinkTaskPriority=unique(SimulinkTaskPriority);
    SimulinkTaskPriorityCopy=SimulinkTaskPriority;




    switch get_param(ModelName,'PositivePriorityOrder')




    case 'on'
        UniqueSimulinkTaskPriority=sort(UniqueSimulinkTaskPriority,'descend');




    case 'off'
        UniqueSimulinkTaskPriority=sort(UniqueSimulinkTaskPriority,'ascend');
    end


    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
    if intdef.PositivePriorityOrder
        startPrio=intdef.PriorityRange(2);
        endPrio=intdef.PriorityRange(1);
        for i=1:numel(UniqueSimulinkTaskPriority)
            currPrio=startPrio-i+1;
            if currPrio<endPrio
                currPrio=endPrio;
            end
            SimulinkTaskPriority(SimulinkTaskPriorityCopy==UniqueSimulinkTaskPriority(i))=currPrio;
        end
    else
        startPrio=intdef.PriorityRange(1);
        endPrio=intdef.PriorityRange(2);
        for i=1:numel(UniqueSimulinkTaskPriority)
            currPrio=startPrio+i-1;
            if currPrio>endPrio
                currPrio=endPrio;
            end
            SimulinkTaskPriority(SimulinkTaskPriorityCopy==UniqueSimulinkTaskPriority(i))=currPrio;
        end
    end
end


function IrqPriorityList=assignProcessorPriorityToTasks(IrqPriorityList,IrqTaskPriority)
    for i=1:numel(IrqPriorityList)
        IrqPriorityList{i}.HwIsrPriority=IrqTaskPriority(i);
    end
end


