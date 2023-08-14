


function errorInfo=checkCompatForSLTStubbedSLFunction(harnessOwner,harnessName)

    errorInfo=checkIfContainsStubbedSimulinkFunction(harnessOwner,harnessName);
end

function match=isStubbedSimulinkFunction(handle)
    match=false;

    tagValue=get_param(handle,'Tag');
    if strcmp(tagValue,'_SLT_SLFunc_Stub_')

        ssType=Simulink.SubsystemType(handle);
        match=ssType.isSimulinkFunction;
    end
end


function errorInfo=checkIfContainsStubbedSimulinkFunction(harnessOwner,harnessName)
    errorInfo.identifier=[];
    errorInfo.message=[];

    if slfeature('SLDVAutosarBSWCallersSupport')



        return;
    end


    blockH=find_system(get_param(harnessName,'Handle'),...
    'FirstResultOnly','on',...
    'SearchDepth',2,...
    'MatchFilter',@isStubbedSimulinkFunction);
    if~isempty(blockH)
        errorInfo.identifier='Sldv:Compatibility:SimFcnAcrossModelBoundaryNotSupported';
        errorInfo.message=getString(message(errorInfo.identifier,...
        getfullname(harnessOwner),...
        get_param(blockH,'Name')));
    end
end


