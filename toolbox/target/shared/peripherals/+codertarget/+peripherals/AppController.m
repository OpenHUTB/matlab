classdef AppController<handle






    properties


PeripheralInfo


ModelName


TaskMappingInfo
    end

    properties(Access=private)

AppModel


AppView
    end




    methods(Access=private)
        function initializePeripheralMappingInfo(obj,hCS,selectedBlock)





            defFile=codertarget.peripherals.utils.getDefFileNameForBoard(hCS);

            obj.AppModel=codertarget.peripherals.AppModel(hCS,defFile);
            [mdlRefs,mdlInfo]=obj.AppModel.getPeripheralInfoForRefModels();

            if~isempty(obj.AppModel.SupportedPeripheralInfo)
                if~isempty(mdlInfo)
                    obj.PeripheralInfo.ModelRefs=mdlRefs;
                    mdlInfo=orderfields(mdlInfo);
                    types=fieldnames(mdlInfo);
                    for i=1:numel(types)
                        peripheralGroupInfo=obj.AppModel.SupportedPeripheralInfo.getPeripheralGroupInfo(types{i});
                        templateInfo.(types{i}).Group=peripheralGroupInfo.GroupParameters;
                        templateInfo.(types{i}).Block=peripheralGroupInfo.BlockParameters;
                        templateInfo.(types{i}).Mask=peripheralGroupInfo.Mask;


                        if~isfield(mdlInfo.(types{i}),'Group')
                            mdlInfo.(types{i}).Group=struct;
                        end


                        groupParams=obj.AppModel.SupportedPeripheralInfo.getGroupParameters(types{i});
                        if~isempty(groupParams)
                            groupParamNames={groupParams.Storage};
                            missingParams=setdiff(groupParamNames,fieldnames(mdlInfo.(types{i}).Group));
                            for j=1:numel(missingParams)
                                idx=find(strcmp({groupParams.Storage},missingParams{j}));
                                mdlInfo.(types{i}).Group.(missingParams{j})=groupParams(idx).Value;%#ok<FNDSB> 
                            end
                        end


                        blockParams=obj.AppModel.SupportedPeripheralInfo.getBlockParameters(types{i});
                        blockParamNames={blockParams.Storage};
                        missingParams=setdiff(blockParamNames,fieldnames(mdlInfo.(types{i}).Block(1)));
                        for j=1:numel(missingParams)
                            idx=find(strcmp({blockParams.Storage},missingParams{j}));

                            for k=1:numel(mdlInfo.(types{i}).Block)
                                mdlInfo.(types{i}).Block(k).(missingParams{j})=blockParams(idx).Value;%#ok<FNDSB>
                            end
                        end
                    end
                    obj.PeripheralInfo.Board=hCS.get_param('HardwareBoard');
                    obj.PeripheralInfo.Model=mdlInfo;
                    obj.PeripheralInfo.Template=templateInfo;
                    if~isempty(selectedBlock)
                        obj.PeripheralInfo.SelectedBlock=selectedBlock;
                    end
                end
            end
        end

        function initializeTaskMappingInfo(obj)


            [mappingData,eventNames]=...
            codertarget.internal.taskmapper.getTaskMappingInfo(obj.ModelName);
            if~isempty(mappingData)
                taskNames=mappingData(:,1);
            else
                taskNames={};
            end
            obj.TaskMappingInfo.ModelName=obj.ModelName;
            obj.TaskMappingInfo.MappingData=mappingData;
            obj.TaskMappingInfo.TaskNames=taskNames;
            obj.TaskMappingInfo.EventNames=eventNames;
        end
    end




    methods
        function obj=AppController(hObj,selectedBlock)



            if isa(hObj,'Simulink.ConfigSet')||...
                isa(hObj,'Simulink.ConfigSetRef')
                hCS=hObj;
            else
                hCS=getActiveConfigSet(hObj);
            end

            if nargin==1
                selectedBlock='';
            end

            obj.ModelName=get_param(hCS.getModel(),'Name');

            obj.AppView=codertarget.peripherals.AppView.getInstance();
            if obj.AppView.isAppOpen()


                obj.AppView.bringToFront();
            else

                obj.AppView.createApp(obj);


                obj.initializePeripheralMappingInfo(hCS,selectedBlock);

                obj.initializeTaskMappingInfo();


                if isempty(obj.PeripheralInfo)&&isempty(obj.TaskMappingInfo.MappingData)
                    obj.AppView.setBusy(false);
                    obj.AppView.showConfirmDlg('No data',...
                    message('codertarget:peripherals:NoHardwareMappingData',obj.ModelName).getString(),...
                    'Exit');
                    obj.AppView.closeApp();
                    return;
                end

                obj.AppView.initializeApp(obj.ModelName,obj.PeripheralInfo,obj.TaskMappingInfo);

                cObj=get_param(hCS.getModel(),'InternalObject');
                cObj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',...
                @(~,~)(obj.AppView.closeApp()));
            end
        end
    end




    methods(Access=public)
        function[status,msg]=applyMappingInfo(obj)



            status=true;
            msg='';

            taskInfoCache=obj.AppView.getTaskInfo();
            peripheralInfoCache=obj.AppView.getPeripheralInfo();

            errInfo=codertarget.internal.taskmapper.preApplyCheck(...
            taskInfoCache.ModelName,...
            taskInfoCache.MappingData,...
            taskInfoCache.EventNames);
            res=cellfun(@(x)~isempty(x),errInfo,'UniformOutput',true);
            if any(res)
                idx=find(res,1);
                err=message(errInfo{idx}.ID,errInfo{idx}.Args{:});
                msg=err.getString();
                status=false;
                return;
            end

            if~isempty(taskInfoCache.TaskNames)
                obj.AppModel.applyTaskMappingInfo(taskInfoCache);
            end
            if~isempty(peripheralInfoCache)
                [status,msg]=obj.AppModel.applyPeripheralMappingInfo(peripheralInfoCache);
            end
        end
    end
end


