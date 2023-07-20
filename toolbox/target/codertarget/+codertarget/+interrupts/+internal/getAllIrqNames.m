function IsrNames=getAllIrqNames(modelName,varargin)
    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(modelName);
    if~isempty(intdef)
        IsrDefs=getAllInterrupts(intdef);
    else
        IsrDefs=[];
    end

    if~isempty(IsrDefs)
        IsrNames={IsrDefs.Name};
    else
        IsrNames='';
    end
end