function configurationIbisAmiManager(block)
    managerHandle=serdes.internal.findMgrWithTag(bdroot(block),'IbisAmiManager');
    if~isempty(managerHandle)&&isvalid(managerHandle)
        managerHandle.toFront;
    else
        mws=get_param(bdroot(block),'ModelWorkspace');
        requiredMWSElements=["TxTree","RxTree","SerdesIBIS"];
        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            serdesIBIS=mws.getVariable('SerdesIBIS');
            TxTree=mws.getVariable('TxTree');
            RxTree=mws.getVariable('RxTree');
            mgr=IbisAmiManager(serdesIBIS,TxTree,RxTree);
            mgrPos=mgr.ManagerFigure.Position;
            simulinkPos=get_param(bdroot(block),'location');
            screensize=get(0,'Screensize');

            padY=30;
            padX=9;
            mgrPos(1)=simulinkPos(1)+padX;
            mgrPos(2)=screensize(4)-simulinkPos(2)-mgrPos(4)-padY;
            mgr.ManagerFigure.Position=mgrPos;
        end
    end
end

