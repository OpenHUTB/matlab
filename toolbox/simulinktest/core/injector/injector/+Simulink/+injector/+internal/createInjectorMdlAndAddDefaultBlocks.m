function newBD=createInjectorMdlAndAddDefaultBlocks(injRefBlkHdl,injMdlName,~)

    if~ishandle(injRefBlkHdl)
        DAStudio.error('Simulink:utility:invalidHandle');
    end
    mdlH=bdroot(injRefBlkHdl);


    if strcmp(get_param(mdlH,'BlockDiagramType'),'library')
        DAStudio.error('Simulink:SltBlkMap:CannotConfigureMapCtxBlkInLib',DAStudio.message('Simulink:SltBlkMap:Injector'),getfullname(mdlH));
    end


    try Simulink.injector.internal.validateInjectorModelName(injMdlName);
    catch ME
        rethrow(ME)
    end


    try
        oldStatusString=get_param(mdlH,'StatusString');
        newStatusString=DAStudio.message('Simulink:SltBlkMap:CreatingCtxModel',injMdlName);
        set_param(mdlH,'StatusString',newStatusString);
        newBD=new_system(injMdlName);
        Simulink.sltblkmap.internal.setMappingContextOnBD(injRefBlkHdl,newBD);
        designStartTime=get_param(mdlH,'StartTime');
        designStopTime=get_param(mdlH,'StopTime');
        designParamBehavior=get_param(mdlH,'DefaultParameterBehavior');
        set_param(newBD,'Solver','FixedStepAuto',...
        'SampleTimeAnnotations','on',...
        'SampleTimeColors','on',...
        'StartTime',designStartTime,...
        'StopTime',designStopTime,...
        'DefaultParameterBehavior',designParamBehavior);
        addDefaultBlocksInInjectorModel(injMdlName);
        open_system(newBD);
        set_param(mdlH,'StatusString',oldStatusString);
    catch ME
        set_param(mdlH,'StatusString',oldStatusString);
        rethrow(ME)
    end
end


function addDefaultBlocksInInjectorModel(mdlName)
    add_block('safetylib/Injector Subsystem',[mdlName,'/Injector Subsystem'],'ShowName','off','Position',[155,149,240,201]);
end

