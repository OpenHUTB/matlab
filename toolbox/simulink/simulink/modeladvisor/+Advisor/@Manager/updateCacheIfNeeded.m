function updateCacheIfNeeded(obj,varargin)


    if~isfield(obj.slCustomizationDataStructure,'checkCellArray')||~exist(obj.getCacheFilePath,'file')

        obj.clearSlCustomizationData('PreserveCache');
        cacheFilePath=obj.getCacheFilePath;
        mp=ModelAdvisor.Preferences;
        needReLoad=true;
        if mp.EnableCustomizationCache&&exist(cacheFilePath,'file')
            try















                dummy1=ModelAdvisor.Action;%#ok<NASGU>
                dummy2=ModelAdvisor.FactoryGroup;%#ok<NASGU>
                dummy3=ModelAdvisor.Procedure;%#ok<NASGU>
                dummy4=ModelAdvisor.InputParameter;%#ok<NASGU>

                if nargin>1&&strcmp(varargin{1},'quickmode')
                    savedVars=load(cacheFilePath,'-mat','VerificationData');
                    needReLoad=~validateCachedSlCustomizationData(savedVars.VerificationData,true);
                else
                    obj.slCustomizationDataStructure=obj.loadCachedSlCustomizationData;
                    needReLoad=~validateCachedSlCustomizationData(obj.slCustomizationDataStructure,false);

                end
            catch
                needReLoad=true;
            end
        end
        if needReLoad
            disp(DAStudio.message('ModelAdvisor:engine:UpdatingModelAdvisorCache'));
            obj.clearSlCustomizationData;
            obj.loadslCustomization;
            if mp.EnableCustomizationCache
                obj.cacheSlCustomizationData();
            end
            disp(DAStudio.message('ModelAdvisor:engine:RefreshCustomizationTips'));
        end
    end

end


function success=validateCachedSlCustomizationData(slCustomizationDataStructure,quickmode)

    if~isfield(slCustomizationDataStructure,'Version')||(slCustomizationDataStructure.Version~=Advisor.Manager.Version)
        success=false;
        return;
    end


    if~isfield(slCustomizationDataStructure,'MACE')
        success=false;
        return;
    end


    lc=matlab.internal.i18n.locale.default;
    if~strcmp(slCustomizationDataStructure.MessagesLocale,lc.Messages)
        success=false;
        return;
    end

    if quickmode

        success=strcmp(matlabroot,slCustomizationDataStructure.matlabroot);
    else






        h=Simulink.PluginMgr();
        h.ExecuteModelAdvisorCustomizations;
        h1=DAServiceManager.OnDemandService;
        h1.Start('ModelAdv');

        cm=DAStudio.CustomizationManager;
        allCallBackFcnListName=cm.getModelAdvisorCheckFcnsName;
        allTaskFcnName=cm.getModelAdvisorTaskFcnsName;
        allTACBFcnName=cm.getModelAdvisorTaskAdvisorFcnsName;
        processCBFcnName=cm.getModelAdvisorProcessFcnsName;
        if compare_callback_function_info(allCallBackFcnListName,slCustomizationDataStructure.callbackFuncInfoStruct.CheckInfo)&&...
            compare_callback_function_info(allTaskFcnName,slCustomizationDataStructure.callbackFuncInfoStruct.TaskInfo)&&...
            compare_callback_function_info(allTACBFcnName,slCustomizationDataStructure.callbackFuncInfoStruct.TaskAdvisorInfo)&&...
            compare_callback_function_info(processCBFcnName,slCustomizationDataStructure.callbackFuncInfoStruct.ProcessCallbackInfo)
            success=true;
        else
            success=false;


            cm.clearModelAdvisorCheckFcns;
        end
    end

end

function same=compare_callback_function_info(fileInfo1,fileInfo2)
    tolerance=1e-07;
    if length(fileInfo1)~=length(fileInfo2)
        same=false;
        return
    end
    checkSizeSum1=0;
    checkSizeSum2=0;
    checkTimestampSum1=0;
    checkTimestampSum2=0;
    filepath1=cell(1,length(fileInfo1));
    filepath2=cell(1,length(fileInfo1));
    for i=1:length(fileInfo1)
        fileInfo1{i}=dir(fileInfo1{i}(1).file);
        filepath1{i}=[fileInfo1{i}.folder,fileInfo1{i}.name];
        filepath2{i}=[fileInfo2{i}.folder,fileInfo2{i}.name];
        checkSizeSum1=checkSizeSum1+fileInfo1{i}.bytes;
        checkSizeSum2=checkSizeSum2+fileInfo2{i}.bytes;
        checkTimestampSum1=checkTimestampSum1+fileInfo1{i}.datenum;
        checkTimestampSum2=checkTimestampSum2+fileInfo2{i}.datenum;
    end




    if~isempty(setxor(filepath1,filepath2))
        same=false;
        return
    end
    if(checkSizeSum1==checkSizeSum2)&&(abs(checkTimestampSum1-checkTimestampSum2)<tolerance)
        same=true;
    else
        same=false;
    end
end
