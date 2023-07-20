


function openUnitConfiguratorDialog(hDlgSource)

    if isa(hDlgSource,'Stateflow.Data')
        c=hDlgSource.getParent();
        blkH=sfprivate('chart2block',c.Id);
    elseif isa(hDlgSource,'Simulink.Block')
        blkH=hDlgSource.handle;
    else
        blkH=hDlgSource.getBlock.handle;
    end
    modelHandle=bdroot(blkH);
    modelName=get_param(modelHandle,'Name');
    ucBlock=Simulink.UnitConfiguratorBlockMgr.getUnitConfiguratorBlock(blkH);
    if ucBlock<0
        configset.highlightParameter(modelName,'AllowedUnitSystems','default','List');
    end

    if ucBlock>=0
        open_system(ucBlock);
    end

end
