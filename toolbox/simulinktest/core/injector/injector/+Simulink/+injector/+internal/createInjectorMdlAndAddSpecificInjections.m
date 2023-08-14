function[injHdl,injSSHdls]=createInjectorMdlAndAddSpecificInjections(parentPath,blkHdls,prtHdls)

    bpList=[];
    rootOfTheModel=bdroot(parentPath);
    if~isempty(prtHdls)
        bpList=Simulink.sltblkmap.internal.getParentBlockPath(prtHdls(1));
        rootOfTheModel=getfullname(bdroot(bpList(1)));
    end


    if~strcmp(rootOfTheModel,parentPath)
        warnMsg={'Simulink:SltBlkMap:PathNotRootAddingAtRoot',DAStudio.message('Simulink:SltBlkMap:Injector'),parentPath,rootOfTheModel};
        Simulink.observer.internal.warn(warnMsg,true,'Simulink:Injector:InjectorCreateState',get_param(rootOfTheModel,'Name'));
        parentPath=rootOfTheModel;
    end
    mdlH=get_param(parentPath,'handle');




    [sysBounds(1),sysBounds(2),sysBounds(3),sysBounds(4)]=Simulink.injector.internal.getSystemBounds(parentPath);
    pos=[sysBounds(1)+5,sysBounds(4)+20,sysBounds(1)+90,sysBounds(4)+72];


    injHdl=add_block('safetylib/Injector',[parentPath,'/Injector'],'MakeNameUnique','on','Position',pos);


    uniqueInjMdlName=Simulink.sltblkmap.internal.getUniqueCtxMdlName([get_param(bdroot(parentPath),'Name'),'_Injector']);


    try Simulink.injector.internal.validateInjectorModelName(uniqueInjMdlName);
    catch ME
        rethrow(ME)
    end

    set_param(injHdl,'InjectorModelName',uniqueInjMdlName);


    try
        oldStatusString=get_param(mdlH,'StatusString');
        newStatusString=DAStudio.message('Simulink:SltBlkMap:CreatingCtxModel',uniqueInjMdlName);
        set_param(parentPath,'StatusString',newStatusString);
        newBD=new_system(uniqueInjMdlName);
        Simulink.sltblkmap.internal.setMappingContextOnBD(injHdl,newBD);
        designStartTime=get_param(mdlH,'StartTime');
        designStopTime=get_param(mdlH,'StopTime');
        designParamBehavior=get_param(mdlH,'DefaultParameterBehavior');
        set_param(newBD,'Solver','FixedStepAuto',...
        'SampleTimeAnnotations','on',...
        'SampleTimeColors','on',...
        'StartTime',designStartTime,...
        'StopTime',designStopTime,...
        'DefaultParameterBehavior',designParamBehavior);
        load_system(newBD);
        set_param(parentPath,'StatusString',oldStatusString);
    catch ME
        set_param(parentPath,'StatusString',oldStatusString);
        rethrow(ME)
    end



    if isempty(blkHdls)&&isempty(prtHdls)

        injSSName=[uniqueInjMdlName,'/Injector Subsystem'];
        injSSHdl=add_block('sltestlib/Injector Subsystem',injSSName,'ShowName','off','Position',[155,149,240,201]);
        injSSHdls=struct('InjSSHdl',injSSHdl,'InjIpHdl',get_param([injSSName,'/InjectorInport'],'Handle'),'InjOpHdl',get_param([injSSName,'/InjectorOutport'],'Handle'));
        return;
    end

    injSSHdls=struct('InjSSHdl',cell(1,numel(blkHdls)+numel(prtHdls)),'InjIpHdl',[],'InjOpHdl',[]);
    for j=1:numel(blkHdls)
        [injSSHdl,injInHdls,injOutHdls]=Simulink.injector.internal.createInjectorSSForBlockInInjector({bpList(1:end-1),blkHdls(j)},uniqueInjMdlName,false,false);
        injSSHdls(j).InjSSHdl=injSSHdl;
        injSSHdls(j).InjIpHdl=injInHdls;
        injSSHdls(j).InjOpHdl=injOutHdls;
    end

    for j=1:numel(prtHdls)
        [injSSHdl,injInHdls,injOutHdls]=Simulink.injector.internal.createInjectorSSForSignalInInjector({bpList(1:end-1),prtHdls(j)},uniqueInjMdlName,false,false);
        injSSHdls(j+numel(blkHdls)).InjSSHdl=injSSHdl;
        injSSHdls(j+numel(blkHdls)).InjIpHdl=injInHdls;
        injSSHdls(j+numel(blkHdls)).InjOpHdl=injOutHdls;
    end

end

