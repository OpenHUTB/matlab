function[obsHandle,obsPortHandles]=createObserverMdlAndAddSpecificPorts(parentPath,prtHdls,showAndSelect)



    bpList=[];
    rootOfTheModel=bdroot(parentPath);
    if~isempty(prtHdls)
        bpList=Simulink.sltblkmap.internal.getParentBlockPath(prtHdls(1));
        rootOfTheModel=getfullname(bdroot(bpList(1)));
    end


    if~strcmp(rootOfTheModel,parentPath)
        warnMsg={'Simulink:SltBlkMap:PathNotRootAddingAtRoot',DAStudio.message('Simulink:SltBlkMap:Observer'),parentPath,rootOfTheModel};
        Simulink.observer.internal.warn(warnMsg,true,'Simulink:Observer:ObserverCreateState',get_param(rootOfTheModel,'Name'));
        parentPath=rootOfTheModel;
    end
    mdlH=get_param(parentPath,'handle');




    sysBounds=get_param(parentPath,'SystemBounds');
    pos=[sysBounds(1)+5,sysBounds(4)+20,sysBounds(1)+90,sysBounds(4)+72];


    obsHandle=add_block('sltestlib/Observer',[parentPath,'/Observer'],'MakeNameUnique','on','Position',pos);


    uniqueObsMdlName=Simulink.sltblkmap.internal.getUniqueCtxMdlName([get_param(bdroot(parentPath),'Name'),'_Observer']);


    Simulink.observer.internal.validateObserverModelName(uniqueObsMdlName);

    set_param(obsHandle,'ObserverModelName',uniqueObsMdlName);


    try
        oldStatusString=get_param(mdlH,'StatusString');
        newStatusString=DAStudio.message('Simulink:SltBlkMap:CreatingCtxModel',uniqueObsMdlName);
        set_param(parentPath,'StatusString',newStatusString);
        newBD=new_system(uniqueObsMdlName);
        Simulink.sltblkmap.internal.setMappingContextOnBD(obsHandle,newBD);
        designStartTime=get_param(mdlH,'StartTime');
        designStopTime=get_param(mdlH,'StopTime');
        designParamBehavior=get_param(mdlH,'DefaultParameterBehavior');
        designSolver=get_param(mdlH,'Solver');
        designLoggingSetting=get_param(mdlH,'SignalLogging');
        designDataFormat=get_param(mdlH,'SaveFormat');
        designSaveSimState=get_param(mdlH,'SaveCompleteFinalSimState');
        designDSMLogging=get_param(mdlH,'DSMLogging');
        set_param(newBD,'Solver',designSolver,...
        'SampleTimeAnnotations','on',...
        'SampleTimeColors','on',...
        'StartTime',designStartTime,...
        'StopTime',designStopTime,...
        'DefaultParameterBehavior',designParamBehavior,...
        'SaveTime','off',...
        'SaveState','off',...
        'SaveOutput','off',...
        'SaveFinalState','off',...
        'SaveFormat',designDataFormat,...
        'SaveCompleteFinalSimState',designSaveSimState',...
        'SignalLogging',designLoggingSetting,...
        'DSMLogging',designDSMLogging,...
        'LoggingToFile','off');
        open_system(newBD);
        set_param(parentPath,'StatusString',oldStatusString);
    catch ME
        set_param(parentPath,'StatusString',oldStatusString);
        rethrow(ME)
    end


    obsPortHandles=[];
    if~isempty(prtHdls)
        obsPortHandles=Simulink.observer.internal.addObserverPortsForSignalsInObserver({bpList(1:end-1),prtHdls},uniqueObsMdlName,showAndSelect);
        if strcmp(get_param(mdlH,'Open'),'on')

            Simulink.scrollToVisible(obsHandle);
            set_param(obsHandle,'Selected','on');
        end
    end



    Simulink.observer.internal.openObserverMdlFromObsRefBlk(obsHandle);

end
