function blkPortInfo=getBlockPortInfo(blockHandle)






    assert(ishandle(blockHandle)&&isequal(get_param(blockHandle,'Type'),'block'),...
    message('Simulink:HiliteTool:ExpectedBlockHandle'));

    ph=get_param(blockHandle,'PortHandles');
    ip=ph.Inport;
    op=ph.Outport;
    ip_line=arrayfun(@(x)get_param(x,'Line'),ip);
    op_line=arrayfun(@(x)get_param(x,'Line'),op);

    blkPortInfo.blockHasInputPort=~isempty(ip);
    blkPortInfo.blockHasOutputPort=~isempty(op);

    blkPortInfo.blockHasInputConnection=~all(ip_line==-1);
    blkPortInfo.blockHasOutputConnection=~all(op_line==-1);
end