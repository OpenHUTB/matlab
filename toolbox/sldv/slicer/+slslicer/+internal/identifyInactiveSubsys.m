function yesorno=identifyInactiveSubsys(subsysH)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>    
    sysO=get(subsysH,'Object');
    if isa(sysO,'Simulink.SubSystem')
        allblks=sysO.getCompiledBlockList;
        yesorno=locIsActionPort(allblks);
    elseif isa(sysO,'Simulink.ModelReference')
        refName=sysO.ModelName;
        refO=get_param(refName,'Object');
        allblks=refO.getCompiledBlockList;
        yesorno=locIsActionPort(allblks);
    else
        yesorno=false;
    end
end


function out=locIsActionPort(blkH)
    out=false;
    for index=1:length(blkH)
        blkh=blkH(index);
        blktype=get(blkh,'blocktype');
        expActionPorts={'ActionPort','EnablePort','TriggerPort'};
        if ismember(blktype,expActionPorts)
            out=true;
            return
        end
    end
end
