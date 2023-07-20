function out=getParameterDialogInfo(hObj)






    out.standard=codertarget.options.standard(hObj);
    out.simdiagnostics={};
    out.hwdiagnostics={};
    out.simulation={};
    out.schedulers=[];
    out.parameters=[];
    if~isempty(codertarget.data.getData(hObj))
        out.rtos=codertarget.utils.getRTOSWidgets(hObj);
        out.schedulers=codertarget.utils.getSchedulerWidgets(hObj);
        out.parameters=codertarget.parameter.getParameterDialogInfo(hObj,true);
        out.parameters=loc_addExtModeWidgets(hObj,out.parameters);

        out.parameters.ParameterGroupShortNames=cell(1,numel(out.parameters.ParameterGroups));
        if loc_isSoCCompatible(hObj,1)
            out.simdiagnostics=codertarget.utils.getSimulationDiagnosticsWidgets(hObj);
            out.hwdiagnostics=codertarget.utils.getHardwareDiagnosticsWidgets(hObj);
            out.simulation=codertarget.utils.getSimulationWidgets(hObj);
        end
        if loc_isSoCCompatible(hObj,2)&&...
            (codertarget.utils.isMdlConfiguredForSoC(hObj)||...
            loc_isFPGAOnlyBoard(hObj))
            out.parameters=loc_addFPGADesignWidgets(hObj,out.parameters,'TopLevel');
            out.parameters=loc_addFPGADesignWidgets(hObj,out.parameters,'MemControllersPS');
            out.parameters=loc_addFPGADesignWidgets(hObj,out.parameters,'MemControllersPL');
            out.parameters=loc_addFPGADesignWidgets(hObj,out.parameters,'Debug');
        end
    end
end


function in=loc_addExtModeWidgets(hObj,in)
    [info,e]=codertarget.utils.getExtModeWidgets(hObj.getConfigSet);
    if~isempty(e)
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('codertarget:build:ExternalModeWidgetCreationFailed',e.message),'Error',true);
        return;
    end
    if~isempty(info.Parameters)
        [found,idx]=ismember('External mode',in.ParameterGroups);
        if found

            tempParams={};
            for i=1:numel(in.Parameters{idx})
                allKnownStorage{i}=in.Parameters{idx}{i}.Storage;%#ok<AGROW>
            end
            for ii=1:numel(info.Parameters{1})
                if~ismember(info.Parameters{1}{ii}.Storage,allKnownStorage)
                    tempParams{end+1}=info.Parameters{1}{ii};%#ok<AGROW>
                end
            end
            in.Parameters{idx}=[tempParams,in.Parameters{idx}];
        else

            in.ParameterGroups{end+1}='External mode';
            in.Parameters{numel(in.ParameterGroups)}=info.Parameters{1};
        end
    end
end


function in=loc_addProfilerWidgets(hObj,in)
    [info,e]=codertarget.utils.getProfilerWidgets(hObj.getConfigSet);
    if~isempty(e)
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('codertarget:ui:ProfilerWidgetCreationFailed',e.message),'Error',true);
        return;
    end
    grpname=DAStudio.message('codertarget:ui:ProfilerGroupName');
    if~isempty(info.Parameters)
        [found,idx]=ismember(grpname,in.ParameterGroups);
        if found

            tempParams={};
            for i=1:numel(in.Parameters{idx})
                allKnownStorage{i}=in.Parameters{idx}{i}.Storage;%#ok<AGROW>
            end
            for ii=1:numel(info.Parameters{1})
                if~ismember(info.Parameters{1}{ii}.Storage,allKnownStorage)
                    tempParams{end+1}=info.Parameters{1}{ii};%#ok<AGROW>
                end
            end
            in.Parameters{idx}=[tempParams,in.Parameters{idx}];
        else

            in.ParameterGroups{end+1}=grpname;
            in.Parameters{numel(in.ParameterGroups)}=info.Parameters{1};
        end
    end
end


function in=loc_addFPGADesignWidgets(hObj,in,groupName)
    [info,e]=codertarget.utils.getFPGADesignWidgets(hObj.getConfigSet,groupName);
    if~isempty(e)
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('codertarget:ui:FPGADesignWidgetCreationFailed',e.message),'Error',true);
        return;
    end
    groupName=DAStudio.message(['codertarget:ui:FPGADesignGroup',groupName]);
    if~isempty(info.Parameters)
        [found,idx]=ismember(groupName,in.ParameterGroups);
        if found

            tempParams={};
            for i=1:numel(in.Parameters{idx})
                allKnownStorage{i}=in.Parameters{idx}{i}.Storage;%#ok<AGROW>
            end
            for ii=1:numel(info.Parameters{1})
                if~ismember(info.Parameters{1}{ii}.Storage,allKnownStorage)
                    tempParams{end+1}=info.Parameters{1}{ii};%#ok<AGROW>
                end
            end
            in.Parameters{idx}=[tempParams,in.Parameters{idx}];
        else

            in.ParameterGroups{end+1}=groupName;
            in.Parameters{numel(in.ParameterGroups)}=info.Parameters{1};
            in.ParameterGroupShortNames{end+1}='soc';
        end
    end
end


function res=loc_isSoCCompatible(hCS,reqCaps)
    res=isequal(exist('esb_task','file'),3)&&codertarget.targethardware.isESBCompatible(hCS,reqCaps);
end


function out=loc_isFPGAOnlyBoard(hObj)
    hCS=hObj.getConfigSet();
    info=codertarget.targethardware.getTargetHardware(hCS);
    out=isequal(info.ESBCompatible,2);
end
