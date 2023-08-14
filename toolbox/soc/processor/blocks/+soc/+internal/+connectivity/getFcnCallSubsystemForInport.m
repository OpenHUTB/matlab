function out=getFcnCallSubsystemForInport(port)




    import soc.internal.connectivity.*

    subs=soc.internal.connectivity.getMyRightConnections(port);
    assert(numel(subs)==1,...
    'Fcn call port not connected or connected to multiple blocks');

    if~isequal(get_param(subs.DstBlock,'BlockType'),'SubSystem')
        res=isequal(get_param(subs.DstBlock,'BlockType'),...
        'AsynchronousTaskSpecification');
        assert(res,...
        'Function-call port not connected to a subsystem or Asynchronous Task Specification block');
        pc=get_param(subs.DstBlock,'PortConnectivity');
        subs=[];
        for i=1:numel(pc)
            if~isempty(pc(i).DstBlock)
                subs=pc(i);
                break;
            end
        end
        assert(~isempty(subs),...
        'Asynchronous Task Specification block is not connected');
    end

    res=isSubsystemFcnCallPort(subs.DstBlock,subs.DstPort);
    assert(res,...
    'Function-call port not connected to a subsystem or Asynchronous Task Specification block');
    out=subs.DstBlock;
end