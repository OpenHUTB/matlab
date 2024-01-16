function initOutputModel(srcModelName,targetModelName)

    if isempty(srcModelName)
        return;
    end

    copyModelWorkSpace(srcModelName,targetModelName);
    setModelParam(srcModelName,targetModelName);
    dd=get_param(srcModelName,'DataDictionary');
    set_param(targetModelName,'DataDictionary',dd);

    if~isempty(srcModelName)
        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
        dto=get_param(srcModelName,'DataTypeOverride');
        if nfpMode&&contains(dto,'Single')
            set_param(targetModelName,'DataTypeOverride','Single');
        end
    end

    sobj=get_param(srcModelName,'Object');
    configSet=sobj.getActiveConfigSet;
    configSet2=copy(configSet);

    [lwarn_msg,lwarn_id]=lastwarn;
    wstatus=warning;
    slwstatus=sllastwarning;

    configSet2.setPropEnabled('Name',1);
    configSet2.Name='ElaboratedModelConfiguration';
    attachConfigSet(targetModelName,configSet2);
    setActiveConfigSet(targetModelName,'ElaboratedModelConfiguration');
    processSimscape(targetModelName,configSet2);
    setGeneratedModelParameters(targetModelName);

    warning(wstatus);
    lastwarn(lwarn_msg,lwarn_id);
    sllastwarning(slwstatus);
end


function[]=copyModelWorkSpace(srcModelName,targetModelName)
    doNotList='isDirty';
    srcWorkSpace=get_param(srcModelName,'ModelWorkspace');
    targetWorkSpace=get_param(targetModelName,'ModelWorkspace');
    fn=fieldnames(srcWorkSpace);
    for i=1:numel(fn)
        prop=fn{i};
        try
            value=srcWorkSpace.(prop);
        catch
            continue;
        end
        if isempty(strfind(doNotList,prop))
            targetWorkSpace.(prop)=value;
        end
    end
    try
        targetWorkSpace.reload;
    catch

    end

    data=srcWorkSpace.data;

    for idx=1:length(data),
        assignin(targetWorkSpace,data(idx).Name,data(idx).Value);
    end
    set_param(targetModelName,'ParameterArgumentNames','');
    copySfMachineParentedData(srcModelName,targetModelName);
end


function copySfMachineParentedData(srcModelName,targetModelName)

    bd=get_param(srcModelName,'Object');
    d=bd.find('-isa','Stateflow.Data','-depth',1);
    if~isempty(d)
        clip=Stateflow.Clipboard;
        clip.copy(d);
        bd2=get_param(targetModelName,'Object');
        machineId=sfprivate('acquire_or_create_machine_for_model',bd2.Handle);
        m=idToHandle(sfroot,machineId);
        clip.pasteTo(m);
    end
end



function setModelParam(srcModelName,targetModelName)
    exceptions=['Name','CurrentBlock','HDLConfigFile','RTWOptions','Shown','Open'];
    object=get_param(srcModelName,'ObjectParameters');
    field=fieldnames(object);
    for i=1:numel(field)
        prop=field{i};
        if isempty(strfind(exceptions,prop))
            attr=cell2mat((object.(prop).Attributes));
            if isempty(strfind(attr,'read-only'))&&...
                isempty(strfind(attr,'never-save'))&&...
                isempty(strfind(attr,'write-only'))
                try
                    val=get_param(srcModelName,prop);
                    if strcmp(prop,'HDLParams')
                        newHDLParams=slprops.hdlmdlprops;
                        if~isempty(val)
                            newHDLParams.mdlProps=val.mdlProps;

                            index=find(cellfun(@(x)isequal(x,'HDLSubsystem'),newHDLParams.mdlProps));
                            if~isempty(index)
                                newHDLParams.mdlProps{index+1}='';
                            end
                            set_param(targetModelName,prop,newHDLParams);
                        else
                            set_param(targetModelName,prop,val);
                        end
                    else
                        set_param(targetModelName,prop,val);
                    end
                catch
                end
            end
        end
    end
    pos=get_param(targetModelName,'Location');
    set_param(targetModelName,'Location',pos+20);

    try
        hws=get_param(targetModelName,'modelworkspace');
        hws.reload;
    catch

    end
end


function processSimscape(targetModelName,configSet)
    a=configSet.getComponent('Simscape');
    if~isempty(a)&&strcmp(get_param(targetModelName,'EditingMode'),'Restricted')
        set_param(targetModelName,'EditingMode','Full');
    end
end


function setGeneratedModelParameters(targetModelName)
    set_param(targetModelName,'CloseFcn','');
    set_param(targetModelName,'LoggingToFile','off');
end


