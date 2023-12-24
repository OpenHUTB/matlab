function sendBlockToObserver(blk,obs,showAndSelect)

    blk=getfullname(blk);
    blkH=get_param(blk,'Handle');
    parent=get_param(blk,'Parent');
    bpList=Simulink.sltblkmap.internal.getParentBlockPath(blkH);

    createNewObserver=isempty(obs);
    if~createNewObserver
        for j=1:numel(bpList)
            if bdroot(bpList(j))==get_param(bdroot(get_param(obs,'ObserverContext')),'Handle')
                bpList=bpList(j:end);
                break;
            end
        end
    end

    parent=getfullname(bdroot(bpList(1)));

    pHandles=get_param(blk,'PortHandles');
    blkName=get_param(blk,'Name');
    blkName=strrep(blkName,newline,' ');

    if ismember(get_param(blk,'BlockType'),{'Outport','Goto','DataStoreWrite','ArgOut'})
        DAStudio.error('Simulink:Observer:CannotConvertToObserver');
    end
    prtArrayOut=[pHandles.Outport,pHandles.State];
    if~isempty(prtArrayOut)
        DAStudio.error('Simulink:Observer:CannotConvertBlockWithOutports',blkName);
    end

    prtArrayConn=[pHandles.LConn,pHandles.RConn];
    if~isempty(prtArrayConn)
        DAStudio.error('Simulink:Observer:CannotConvertBlockWithConnectionPorts',blkName);
    end
    prtArrayIn=[pHandles.Inport,pHandles.Enable,pHandles.Trigger,pHandles.Ifaction,pHandles.Reset];
    if isempty(prtArrayIn)
        DAStudio.error('Simulink:Observer:CannotConvertBlockWithoutInports',blkName);
    end


    if strcmp(get_param(bdroot(blkH),'IsObserverBD'),'on')
        DAStudio.error('Simulink:Observer:CannotConvertBlockAlreadyInsideObserver',blkName);
    end

    if createNewObserver
        try
            Simulink.observer.internal.checkCanAddObserverInSubsystem(get_param(parent,'Handle'));
        catch ME
            throwAsCaller(ME);
        end
    end

    if strcmp(get_param(blk,'BlockType'),'SubSystem')
        try
            Simulink.observer.internal.checkCanConvertSubsystemToObserver(get_param(blk,'Handle'));
        catch ME
            throwAsCaller(ME);
        end
    end

    nPrtIn=numel(prtArrayIn);
    srcPrtList=zeros(nPrtIn,1);
    blkHList=zeros(nPrtIn,1);
    prtIdxList=zeros(nPrtIn,1);

    for j=1:nPrtIn
        line=get_param(prtArrayIn(j),'Line');

        if line==-1
            DAStudio.error('Simulink:Observer:CannotConvertBlockWithUnconnectedInports',blkName);
        end
        srcPrtList(j)=get_param(line,'SrcPortHandle');
        if srcPrtList(j)==-1
            DAStudio.error('Simulink:Observer:CannotConvertBlockWithUnconnectedInports',blkName);
        end
        srcBlkH=get_param(line,'srcBlockHandle');
        blkHList(j)=srcBlkH;
        prtIdxList(j)=get_param(srcPrtList(j),'PortNumber');
    end

    [~,fidx,ridx]=unique([blkHList,prtIdxList],'rows','stable');
    nObsPorts=numel(fidx);

    if isa(get_param(blk,'Object'),'Simulink.SubSystem')
        dp=DAStudio.DialogProvider;
        dp.questdlg(DAStudio.message('Simulink:Observer:ConfirmSendToObserverMsg',blkName,obs),...
        DAStudio.message('Simulink:Observer:ConfirmSendToObserverTitle',blkName),...
        {DAStudio.message('Simulink:Observer:Yes'),...
        DAStudio.message('Simulink:Observer:No')},...
        DAStudio.message('Simulink:Observer:No'),...
        @(choice)confirmconvert(choice));
    else
        confirmconvert(DAStudio.message('Simulink:Observer:Yes'));
    end

    function confirmconvert(choice)
        if~strcmp(choice,DAStudio.message('Simulink:Observer:Yes'))
            return;
        end

        if createNewObserver
            [obsH,~]=Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(parent,[],'off');

            if strcmp(get_param(parent,'Open'),'on')
                Simulink.scrollToVisible(obsH);
                set_param(obsH,'Selected','on');
            end
            obs=get_param(obsH,'ObserverModelName');
        end

        existingObsPrtBlks=Simulink.observer.internal.getObserverPortsInsideObserverModel(get_param(obs,'Handle'));
        for k=1:numel(existingObsPrtBlks)
            obj=get_param(existingObsPrtBlks(k),'Object');
            obj.hilite('none');
        end
        blkH=add_block(blk,[obs,'/',blkName],'MakeNameUnique','on');
        for k=1:nPrtIn
            line0=get_param(prtArrayIn(k),'Line');
            delete_line(line0);
            if get_param(srcPrtList(k),'Line')==-1

                pos=get_param(srcPrtList(k),'Position');
                parentSys=get_param(get_param(srcPrtList(k),'Parent'),'Parent');
                termBlk=add_block('built-in/Terminator',[parentSys,'/Terminator'],'MakeNameUnique','on','ShowName','off','Position',[pos+[60,-10],pos+[80,10]]);
                termPrts=get_param(termBlk,'PortHandles');
                add_line(parentSys,srcPrtList(k),termPrts.Inport(1),'AutoRouting','on');
            end
        end

        warnStat1=warning('off','Simulink:IOManager:ViewerConnectionNotValid');
        warnStat2=warning('off','Simulink:Harness:HarnessDeletedForBlock');
        wCleanup1=onCleanup(@()warning(warnStat1.state,'Simulink:IOManager:ViewerConnectionNotValid'));
        wCleanup2=onCleanup(@()warning(warnStat2.state,'Simulink:Harness:HarnessDeletedForBlock'));
        isRootLevelBlock=isa(get_param(get_param(blk,'Parent'),'Object'),'Simulink.BlockDiagram');
        delete_block(blk);
        if createNewObserver&&isRootLevelBlock
            newName=blkName;
            counter=1;
            parentPath=[getfullname(get_param(obsH,'Parent')),'/'];
            while getSimulinkBlockHandle([parentPath,newName])~=-1
                newName=[blkName,num2str(counter)];
                counter=counter+1;
            end
            set_param(obsH,'Name',newName);
        end
        pHandles=get_param(blkH,'PortHandles');
        prtArrayIn=[pHandles.Inport,pHandles.Enable,pHandles.Trigger,pHandles.Ifaction,pHandles.Reset];
        insertObserverPorts();
    end


    function insertObserverPorts()
        currBound=get_param(obs,'SystemBounds');
        pos=get_param(blkH,'Position');
        xpos=pos(1)-200;
        if~isempty(pHandles.Inport)
            yfirst=get_param(pHandles.Inport(1),'Position');
            yend=get_param(pHandles.Inport(end),'Position');
            nInObsPorts=numel(unique(ridx(1:numel(pHandles.Inport))));
            if yend(2)-yfirst(2)<=44*(nInObsPorts-1)
                ypos=(0.5*(pos(2)+pos(4))-22*nInObsPorts-35)+44*(1:nInObsPorts);
            elseif nInObsPorts>1
                ypos=linspace(yfirst(2),yend(2),nInObsPorts)-13;
            else
                ypos=0.5*(yfirst(2)+yend(2))-13;
            end
            yposmin=min(ypos(1),pos(2));
        else
            ypos=[];
            yposmin=pos(2);
        end
        nCtrlObsPorts=numel(setdiff(ridx(numel(pHandles.Inport)+1:end),ridx(1:numel(pHandles.Inport))));
        if nCtrlObsPorts~=0
            ypos=[ypos,yposmin-44*(1:nCtrlObsPorts)];
        end

        if~createNewObserver

            dx=xpos-currBound(1)-5;
            dy=min(min(ypos),pos(2))-currBound(4)-5;
            set_param(blkH,'Position',pos-[dx,dy,dx,dy]);
            xpos=xpos-dx;
            ypos=ypos-dy;
        end

        obsPrtBlks=zeros(1,nObsPorts);
        obsPrtLines=zeros(1,nPrtIn);
        for k=1:nPrtIn
            line0=get_param(prtArrayIn(k),'line');
            if line0~=-1
                inpH=get_param(line0,'SrcPortHandle');
                delete_line(line0);
                if inpH~=-1
                    delete_block(get_param(inpH,'Parent'));
                end
            end
            if ismember(k,fidx)
                obsPrtBlks(ridx(k))=add_block('sltestlib/ObserverPort',[obs,'/Observer Port'],'MakeNameUnique','on',...
                'ShowName','off','Position',[xpos,ypos(ridx(k)),xpos+45,ypos(ridx(k))+26]);
                Simulink.observer.internal.configureObserverPort(obsPrtBlks(ridx(k)),'Outport',[bpList(1:end-1),blkHList(k)],prtIdxList(k));
            end
            pH=get_param(obsPrtBlks(ridx(k)),'PortHandles');
            obsPrtLines(k)=add_line(obs,pH.Outport(1),prtArrayIn(k),'AutoRouting','on');
        end

        objs=find_system(obs,'SearchDepth',1,'FindAll','on','Selected','on');
        arrayfun(@(x)set_param(x,'Selected','off'),objs);
        if showAndSelect
            for k=1:nPrtIn
                set_param(obsPrtBlks(ridx(k)),'Selected','on');
                set_param(obsPrtLines(k),'Selected','on');
            end
            set_param(blkH,'Selected','on');
            if~strcmp(get_param(obs,'open'),'on')
                open_system(obs,'window');
            end
        end
    end
end

