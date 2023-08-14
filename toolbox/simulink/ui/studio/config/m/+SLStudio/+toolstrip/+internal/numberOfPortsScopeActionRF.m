



function numberOfPortsScopeActionRF(cbinfo,action)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);

    if isempty(blocks)||~strcmp(blocks.type,'Scope')
        return;
    end

    bh=blocks.handle;

    nInports=get_param(bh,'NumInputPorts');
    action.text=nInports;
end
