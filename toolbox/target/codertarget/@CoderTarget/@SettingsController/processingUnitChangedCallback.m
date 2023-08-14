function processingUnitChangedCallback(hObj,hDlg,tag,arg)






    if loc_isShowWaitBar(hObj)
        waitbarHandle=waitbar(0,DAStudio.message('codertarget:build:InitializingParamWaitMsg'));
        callbackObj=onCleanup(@()progressBarCleanup(waitbarHandle));
    end
    loc_resetProgUnitSpecificCoderTargetData(hObj);
    widgetChangedCallback(hObj,hDlg,tag,arg);
    codertarget.data.initializeTargetData(hObj,'update')
    hCS=hObj.getConfigSet;
    procUnitInfo=codertarget.targethardware.getHardwareConfiguration(hCS);
    codertarget.internal.setToolChain(hCS,procUnitInfo);
    codertarget.internal.setProdHWDeviceType(hCS,procUnitInfo.ProdHWDeviceType);
    attributeInfo=codertarget.attributes.getProcessingUnitAttributes(procUnitInfo);
    if~isempty(attributeInfo)&&~isempty(attributeInfo.getOnHardwareSelectHook)
        feval(attributeInfo.getOnHardwareSelectHook,hCS);
    end


    loc_setRuntimeCpuC28x(hCS);

    hCS.refreshDialog();
end


function loc_resetProgUnitSpecificCoderTargetData(hObj)



    hwSpecificFields={'UseCoderTarget','TargetHardware','ESB','DataVersion'};
    coderTargetData=codertarget.data.getData(hObj);
    allFields=fieldnames(coderTargetData);
    for i=1:numel(allFields)
        if~any(strcmp(hwSpecificFields,allFields{i}))
            coderTargetData.(allFields{i})=[];
            coderTargetData=rmfield(coderTargetData,allFields{i});
        end
    end
    hObj.set_param('DialogTemplateData',[]);
    hObj.set_param('CoderTargetData',coderTargetData);
end


function ret=loc_isShowWaitBar(hCS)
    try
        ret=~isequal(get_param(hCS.getModel,'BuildInProgress'),'on');
    catch

        ret=true;
    end
end

function progressBarCleanup(waitbarHandle)
    if~isempty(waitbarHandle)&&waitbarHandle.isvalid
        waitbarHandle.delete;
    end
end

function loc_setRuntimeCpuC28x(hCS)

    hwBoard=get_param(hCS,'HardwareBoard');
    if(~isempty(regexp(hwBoard,'TI Delfino F2837\wD','match','once'))||...
        ~isempty(regexp(hwBoard,'TI F2838\wD','match','once')))&&...
        codertarget.data.isValidParameter(hCS,'Runtime.CPU')
        puName=codertarget.targethardware.getProcessingUnitName(hCS);
        if~isequal(puName,'None')
            codertarget.data.setParameterValue(hCS,'Runtime.CPU',puName(end-3:end));
        end
    end
end

