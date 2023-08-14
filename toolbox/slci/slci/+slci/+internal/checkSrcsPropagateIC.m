








function out=checkSrcsPropagateIC(blkH)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    blockType=get_param(blkH,'BlockType');
    out=false;
    assert(strcmp(blockType,'Outport'));
    blockObject=get_param(blkH,'Object');



    srcPort=blockObject.getBoundedSrc;
    srcPortNum=size(srcPort,1);

    out=(srcPortNum~=0);

    for i=1:srcPortNum
        portObject=get_param(srcPort(i,1),'Object');
        srcPropagateIC=portObject.getICAttribsComputeInStart||...
        portObject.getICAttribsComputeInFirstInit;
        if~srcPropagateIC
            out=false;
            break;
        end
    end

end
