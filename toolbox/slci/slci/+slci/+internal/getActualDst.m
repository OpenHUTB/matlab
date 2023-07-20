function[actDst]=getActualDst(blkH,port)









    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        pH=get_param(blkH,'PortHandles');
        outObj=get_param(pH.Outport(port+1),'Object');
        adObj=outObj.getActualDst;
        numDsts=size(adObj,1);
        actDst=zeros(0,5);
        sl=slroot;
        for dstIdx=1:numDsts
            dstPortObj=adObj(dstIdx,1);
            if sl.isValidSlObject(dstPortObj)
                dstBlock=get_param(dstPortObj,'ParentHandle');

                dstBlock=slci.internal.getOrigRootIOPort(dstBlock,'Outport');
                dst(1,1)=dstBlock;
                dst(1,2)=get_param(dstPortObj,'PortNumber')-1;
                dst(1,3)=adObj(dstIdx,2);
                dst(1,4)=adObj(dstIdx,3);
                dst(1,5)=adObj(dstIdx,4);
                actDst=[actDst;dst];%#ok
            end
        end
    catch ME
        error(['error computing actual dsts for ',get_param(blkH,'Name'),', port ',num2str(port+1)]);
    end


