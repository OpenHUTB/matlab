function isFrameBased=isInputFrameBased(this)





    isFrameBased=true;
    if~this.IsSystemObjectSource
        blockHandle=this.Application.DataSource.BlockHandle.handle;
        ph=get_param(blockHandle,'PortHandles');
        isFrameBased=get_param(ph.Inport(1),'CompiledPortFrameData');
    end
end
