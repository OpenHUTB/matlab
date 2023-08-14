function obsHdl=createObserverMdlAndAddDefaultPorts(obsRefBlkHdl,obsMdlName,openEditor)








    obsHdl=-1.0;%#ok<NASGU>


    if~ishandle(obsRefBlkHdl)
        DAStudio.error('Simulink:utility:invalidHandle');
    end
    mdlH=bdroot(obsRefBlkHdl);


    if strcmp(get_param(mdlH,'BlockDiagramType'),'library')
        DAStudio.error('Simulink:SltBlkMap:CannotConfigureMapCtxBlkInLib',DAStudio.message('Simulink:SltBlkMap:Observer'),getfullname(mdlH));
    end


    if isempty(obsMdlName)

        [~,obsMdlName]=fileparts(tempname);
    end

    try Simulink.observer.internal.validateObserverModelName(obsMdlName);
    catch ME
        rethrow(ME)
    end


    try
        oldStatusString=get_param(mdlH,'StatusString');
        newStatusString=DAStudio.message('Simulink:SltBlkMap:CreatingCtxModel',obsMdlName);
        set_param(mdlH,'StatusString',newStatusString);
        newBD=new_system(obsMdlName);
        Simulink.sltblkmap.internal.setMappingContextOnBD(obsRefBlkHdl,newBD);
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

        copyWorkspaceVariables(get_param(mdlH,'Name'),obsMdlName);

        addDefaultBlocksInObserverModel(obsMdlName);

        if openEditor
            open_system(newBD);
        end

        set_param(mdlH,'StatusString',oldStatusString);
    catch ME
        if ishandle(newBD)
            close_system(newBD,0);
        end
        set_param(mdlH,'StatusString',oldStatusString);
        rethrow(ME)
    end

    obsHdl=newBD;
end


function addDefaultBlocksInObserverModel(mdlName)
    add_block('sltestlib/ObserverPort',[mdlName,'/ObserverPort'],'ShowName','off','Position',[100,87,145,113]);
    add_block('built-in/Terminator',[mdlName,'/Terminator'],'ShowName','off','Position',[240,90,260,110]);
    add_line(mdlName,[145,100;240,100]);
end


function copyWorkspaceVariables(srcModelName,observerModelName)





    if~isempty(get_param(srcModelName,'DataDictionary'))
        return;
    end



    fromModelWksp=get_param(srcModelName,'ModelWorkspace');
    fromModelVars=fromModelWksp.whos;
    toModelWksp=get_param(observerModelName,'ModelWorkspace');

    for idx=1:numel(fromModelVars)
        try
            varName=fromModelVars(idx).name;
            var=fromModelWksp.getVariable(varName);
        catch
            continue;
        end
        toModelWksp.assignin(varName,var);
    end

end
