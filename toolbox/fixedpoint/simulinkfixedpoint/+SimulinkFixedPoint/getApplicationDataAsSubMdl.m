function ApplicationData=getApplicationDataAsSubMdl(model,instanceName)







    s=get_param(model,'MinMaxOverflowArchiveData');
    dirty=get_param(model,'Dirty');


    isApplicationDataWithModelParam=(isfield(s,'ApplicationData'))&&...
    isa(s.ApplicationData,'SimulinkFixedPoint.ApplicationData');

    if~isApplicationDataWithModelParam
        s.ApplicationData=SimulinkFixedPoint.ApplicationData(model);
    end

    if isempty(instanceName)
        ApplicationData=s.ApplicationData;
        return;
    end

    if ischar(instanceName)
        keyValue=getKeyFromBlockName(instanceName);
    else

        keyValue=instanceName;
    end


    if~s.ApplicationData.subDatasetMap.isKey(keyValue)

        instanceObject=get_param(model,'Object');%#ok<NASGU>
        fptRepositoryInstance=fxptds.FPTRepository.getInstance;
        s.ApplicationData.subDatasetMap(keyValue)=fptRepositoryInstance.getDatasetForSource(Simulink.ID.getSID(instanceName));
    end

    set_param(model,'MinMaxOverflowArchiveData',s);
    set_param(model,'Dirty',dirty);
    ApplicationData=s.ApplicationData;

    function keyVal=getKeyFromBlockName(instanceName)

        keyVal=get_param(instanceName,'handle');


