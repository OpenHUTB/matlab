function subsys=createSubSystem(blk)





    clz=class(blk);
    switch clz

    case 'Simulink.BlockDiagram'
        subsys=SigLogSelector.BdNode;
        subsys.daobject=blk;


    case 'char'
        subsys=SigLogSelector.BdNode(blk,true);
        subsys.daobject=[];


    case 'Simulink.ModelReference'
        subsys=SigLogSelector.MdlRefNode;
        subsys.daobject=blk;


    case{'Stateflow.Chart',...
        'Stateflow.LinkChart',...
        'Stateflow.TruthTableChart',...
        'Stateflow.StateTransitionTableChart'}
        subsys=SigLogSelector.SFChartNode;
        subsys.daobject=blk.up;


    case{'Stateflow.State',...
        'Stateflow.Box',...
        'Stateflow.Function',...
        'Stateflow.TruthTable'}
        subsys=SigLogSelector.SFObjectNode;
        subsys.daobject=blk;


    otherwise
        subsys=SigLogSelector.SubSysNode;
        subsys.daobject=blk;

    end


    if~ischar(blk)
        subsys.Name=blk.Name;
        if isa(blk,'Stateflow.Chart')||...
            isa(blk,'Stateflow.LinkChart')||...
            isa(blk,'Stateflow.TruthTableChart')||...
            isa(blk,'Stateflow.StateTransitionTableChart')


            subsys.CachedFullName=...
            Simulink.SimulationData.BlockPath.manglePath(blk.Path);
        else
            subsys.CachedFullName=...
            Simulink.SimulationData.BlockPath.manglePath(blk.getFullName);
        end
    end


    subsys.addListeners;
    subsys.childNodes=Simulink.sdi.Map(' ',?handle);

end
