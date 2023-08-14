



function numberOfPortsScopeActionCB(cbinfo)

    newNumPorts=cbinfo.EventData;

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    assert(isscalar(blocks));
    bh=blocks.handle;

    set_param(bh,'NumInputPorts',newNumPorts);

end

