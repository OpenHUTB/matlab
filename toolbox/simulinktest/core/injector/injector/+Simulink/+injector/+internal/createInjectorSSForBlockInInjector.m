function[injSSHdl,injInHdls,injOutHdls]=createInjectorSSForBlockInInjector(blk,inj,showAndSelect,uiMode)







    blockPath=[];
    if iscell(blk)
        blockPath=blk{1};
        blk=blk{2};
    end

    blk=get_param(blk,'Handle');
    pHandles=get_param(blk,'PortHandles');
    prtArrayIn=[pHandles.Inport,pHandles.Enable,pHandles.Trigger,pHandles.Ifaction,pHandles.Reset];
    prtArrayOut=[pHandles.Outport,pHandles.State];

    if isempty(prtArrayOut)
        DAStudio.error('Simulink:Injector:CannotInjectBlockWithoutOutports',blkName);
    end

    nIn=numel(prtArrayIn);
    nOut=numel(prtArrayOut);

    prtArrayInSrc=zeros(1,nIn);
    for j=1:nIn
        linH=get_param(prtArrayIn(j),'Line');
        if linH==-1
            DAStudio.error('Simulink:Injector:CannotInjectBlockWithUnconnectedInports',blkName);
        end
        prtArrayInSrc(j)=get_param(linH,'SrcPortHandle');
        if prtArrayInSrc(j)==-1
            DAStudio.error('Simulink:Injector:CannotInjectBlockWithUnconnectedInports',blkName);
        end
    end

    injSSHdl=Simulink.injector.internal.addNewEmptyInjectorSS(inj);

    injSSName=getfullname(injSSHdl);

    [injInHdls,injOutHdls]=Simulink.injector.internal.addInjectorPortsForSignalsInInjectorSS([prtArrayInSrc,prtArrayOut],prtArrayOut,injSSName,false);

    for j=1:nIn
        blkH=get_param(get_param(prtArrayInSrc(j),'Parent'),'Handle');
        injSpec=get_param(prtArrayInSrc(j),'PortNumber');
        Simulink.injector.internal.configureInjectorPort(injInHdls(j),'Outport',[blockPath,blkH],injSpec,uiMode);
    end
    for j=1:nOut
        blkH=get_param(get_param(prtArrayOut(j),'Parent'),'Handle');
        injSpec=get_param(prtArrayOut(j),'PortNumber');
        Simulink.injector.internal.configureInjectorPort(injInHdls(nIn+j),'Outport',[blockPath,blkH],injSpec,uiMode);
        Simulink.injector.internal.configureInjectorPort(injOutHdls(j),'Outport',[blockPath,blkH],injSpec,uiMode);
    end

    if showAndSelect
        set_param(injSSHdl,'Selected','on');
        if~strcmp(get_param(inj,'open'),'on')
            open_system(inj,'window');
        end
    end

end

